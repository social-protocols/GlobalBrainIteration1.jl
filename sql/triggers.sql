


create trigger afterInsertVote after insert on Vote
	begin

	update informedVote set vote = new.vote where userId = new.userId and tagId = new.tagId and postId = new.postId ;

	insert into Tally(isRoot, tagId, postId, count, total) values (
		(select parentId from post where id = new.postId) is null,
		new.tagId,
		new.postId,
		(new.vote == 1),
		new.vote != 0
	) on conflict(tagId, postId) do update 
		set 
			total = total + (new.vote != 0),
			count = count + (new.vote == 1)
	;
	end;



create trigger afterUpdateVote after update on Vote
	begin

	update informedVote set vote = new.vote where userId = new.userId and tagId = new.tagId and postId = new.postId ;

	update Tally
		set 
			total = total + (new.vote != 0) - (old.vote != 0),
			count = count + (new.vote == 1) - (old.vote == 1)
	where
		tagId = new.tagId
		and postId = new.postId
	;
	end;




create trigger afterInsertInformedVote after insert on InformedVote
	begin

	insert into InformedTally(tagId, postId, noteId, eventType, count, total) values (
		new.tagId,
		new.postId,
		new.noteId,
		new.eventType,
		(new.vote == 1),
		(new.vote != 0)
	) on conflict(tagId, postId, noteId, eventType) do update
		set
			count = count + (new.vote == 1),
			total = total + (new.vote != 0) 
	;

	end;





create trigger afterUpdateInformedVote after update on InformedVote
	begin
	update InformedTally
		set
			count = count + ((new.vote == 1) - (old.vote == 1)),
			total = total + ((new.vote != 0) - (old.vote != 0))

	where
		tagId = new.tagId
		and postId = new.postId
		and noteId = new.noteId
		and eventType = new.eventType
	;
	end;





create trigger afterInsertOnVoteHistory after insert on VoteHistory
begin


	-- UninformedVote will contains the a record for all notes under any post a user has voted on
	-- if the user was not informed of that note at the time of the vote on the post. The vote value
	-- of this record will contain the latest uninformed vote, and will stop updating after the
	-- user becomes informed.
	-- So every time there is a vote, we need to look at all notes under the post, see if user has NOT been 
	-- exposed to that note, and insert or update an entry in the uninformedVote table accordingly.
	insert into UninformedVote(userId, tagId, postId, noteId, eventType, vote) 
	select
		new.userId,
		new.tagId,
		new.postId, 
		note.id as noteId,
		2,
		new.direction
	from
		Post note 
		left join Vote on (
			vote.userId = new.userId
			and vote.tagId = new.tagId
			and vote.postId = note.id
			and vote.vote != 0
		)
		where
			note.parentId = new.postId
			and Vote.userId is null
	on conflict(userId, tagId, postId, noteId, eventType) do update set
		vote = new.direction
	;

	-- Do the same update for eventType 1 -- look for users who have not been shown note.
	insert into UninformedVote(userId, tagId, postId, noteId, eventType, vote) 
	select
		new.userId,
		new.tagId,
		new.postId, 
		note.id as noteId,
		1,
		new.direction
	from
		Post note 
		left join InformedVote on (
			InformedVote.userId = new.userId
			and InformedVote.tagId = new.tagId
			and InformedVote.postId = new.postId
			and InformedVote.noteId = note.id
			and InformedVote.eventType = 1
			and InformedVote.vote != 0
		)
		where
			note.parentId = new.postId     -- all notes under the post that was voted on
			and note.id != ifnull(new.noteId,0)
			and InformedVote.userId is null  -- that haven't been shown to this user
	on conflict(userId, tagId, postId, noteId, eventType) do update set
		vote = new.direction
	;


	insert into InformedVote(userId, tagId, postId, noteId, eventType, vote, createdAt) 
	select 		
		new.userId,
		new.tagId,
		new.postId,
		new.noteId,
		1, -- 1 means "shown note"
		new.direction,
		new.createdAt
	where new.noteId is not null
	on conflict(userId, tagId, postId, noteId, eventType) do update set
		vote = new.direction
	;


	-- insert or update vote on post given voted on (each notes under this post)
	-- 1. find all notes for this post that this user has voted on
	-- 2. insert or update record by joining to current vote
	insert into InformedVote(userId, tagId, postId, noteId, eventType, vote, createdAt) 
	select
		new.userId,
		new.tagId,
		new.postId, 
		VoteOnNote.postId,
		2, -- 2 means voted on note
		new.direction,
		new.createdAt
	from Vote VoteOnNote
	where
		VoteOnNote.userId = new.userId
		and VoteOnNote.tagId = new.tagId 
		and VoteOnNote.postId in (select id from post where post.parentId = new.postId)	
		and VoteOnNote.vote != 0
	on conflict(userId, tagId, postId, noteId, eventType) do update set
		vote = new.direction
	;


		-- insert or update vote on parent of post that was voted on, given voted on this note
		-- 1. get parent of post that was voted on
		-- 2. insert or update record by joining to current vote
	insert into InformedVote(userId, tagId, postId, noteId, eventType, vote,createdAt) 
	select
		userId,
		tagId,
		ParentVote.postId, -- the parent of the new.postId
		new.postId, -- the note that was voted on
		2, 
		ifnull(ParentVote.vote,0),
		ParentVote.createdAt
	from Post
	left join Vote ParentVote
	where
		Post.id = new.postId 
		and ParentVote.postId = Post.parentId
		and ParentVote.userId = new.userId
		and ParentVote.tagId = new.tagId 

		-- only do this if the vote is not being cleared
		and new.direction != 0
	on conflict(userId, tagId, postId, noteId, eventType) do update set
		-- get the parent vote again. In this onConflict clause, postId will be the parent because that's the record we tried to insert
		vote = (select vote from Vote where postId = postId and userId = userId and tagId = tagId)
	;


	-- when the vote on the note is cleared, delete the informedVote record
	update informedVote 
		set vote = 0
	where
		new.direction = 0
		and userId = new.userId
		and tagId = new.tagId
		and noteId = new.postId
		and eventType = 2
	;

	-- when vote is cleared, update an uninformedVote record
	update uninformedVote 
		set vote=(select vote from Vote where postId = postId and userId = userId and tagId = tagId)
	where
		new.direction = 0
		and userId = new.userId
		and tagId = new.tagId
		and noteId = new.postId
		and eventType = 2
	;

	-- Insert/update the vote record
	insert into Vote(userId, tagId, postId, vote, latestRowid, createdAt) values (
		new.userId,
		new.tagId,
		new.postId,
		new.direction,
		new.rowid,
		new.createdAt
	) on conflict(userId, tagId, postId) do update set
		vote = new.direction
		, latestRowid = new.rowid
	;



end;





create trigger afterInsertUninformedVote after insert on UninformedVote
	begin

	insert into UninformedTally(tagId, postId, noteId, eventType, count, total) values (
		new.tagId,
		new.postId,
		new.noteId,
		new.eventType,
		(new.vote == 1),
		(new.vote != 0)
	) on conflict(tagId, postId, noteId, eventType) do update 
		set 
			count = count + (new.vote == 1),
			total = total + (new.vote != 0)
	;

	end;




create trigger afterUpdateUninformedVote after update on UninformedVote
	begin
	update UninformedTally
		set 
			count = count + (new.vote == 1) - (old.vote == 1),
			total = total + (new.vote != 0) - (old.vote != 0)
	where
		tagId = new.tagId
		and postId = new.postId
		and noteId = new.noteId
		and eventType = new.eventType
	;

	end;




create trigger afterInsertOnPost after insert on Post
	begin


	insert into UninformedVote(userId, tagId, postId, noteId, eventType, vote) 
	with eventTypes as (
		select 1 as eventType UNION ALL select 2 as eventType 
	) 
	select
		vote.userId,
		vote.tagId,
		vote.postId, 
		new.id as noteId,
		eventType,
		vote.vote
	from
		vote
		-- join new
		join eventTypes
		where vote.postId = new.parentId				
	-- there can be no conflicts
	;

	end;



