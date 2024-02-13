function get_score_db()::SQLite.DB
    vote_database_filename = get(ENV, "VOTE_DATABASE_PATH", nothing)
    if vote_database_filename === nothing
        error("Environment variable 'VOTE_DATABASE_PATH' is not set.")
    end
    db = SQLite.DB(vote_database_filename)

    # During development, just drop and create this db each time.
    DBInterface.execute(db, "drop table if exists scoreData")
    DBInterface.execute(
        db,
        """
            create table ScoreData(
                tagId int
                , parentId int
                , postId int not null
                , topNoteId int
                , parentUninformedP real
                , parentInformedP real
                , uninformedP real
                , informedP real
                , count integer
                , total integer
                , selfP real not null
                , snapshotTimestamp integer not null
            ) strict
        """,
    )

    return db
end


function to_detailed_tally(result)::DetailedTally
    # parentId = missing(result[:parentId]) ? nothing : result[:parentId]
    # println("Got result from DB", result)
    return DetailedTally(
        result[:tagId],
        result[:parentId] == 0 ? nothing : result[:parentId],
        result[:postId],
        BernoulliTally(result[:parentCount], result[:parentTotal]),
        BernoulliTally(result[:uninformedCount], result[:uninformedTotal]),
        BernoulliTally(result[:informedCount], result[:informedTotal]),
        BernoulliTally(result[:selfCount], result[:selfTotal]),
    )
end

function get_detailed_tallies(
    db::SQLite.DB,
    tag_id::Union{Int,Nothing},
    post_id::Union{Int,Nothing},
)
    sql_query = """
        select 
            tagId
            , postId as parentId
            , noteId as postId
            , ifnull(currentCount, 0) as parentCount
            , ifnull(currentTotal, 0) as parentTotal
            , ifnull(uninformedCount, 0) uninformedCount
            , ifnull(uninformedTotal, 0) uninformedTotal
            , ifnull(informedCount, 0) informedCount
            , ifnull(informedTotal, 0) informedTotal
            , ifnull(noteCount, 0) as selfCount
            , ifnull(noteTotal, 0) as selfTotal
        from DetailedTally
        where 
            ifnull(tagId = ?,true)
            and postId = ?
    """

    if post_id === nothing
        sql_query = """
            select 
                tagId
                , 0 parentId -- Julia returns null values as 'missing', which makes no sense. It should return 'nothing'. This is our workaround.
                , postId
                , 0 as parentCount
                , 0 as parentTotal
                , 0 as uninformedCount
                , 0 as uninformedTotal
                , 0 as informedCount
                , 0 as informedTotal
                , count as selfCount
                , total as selfTotal
            from Tally
            where 
            ifnull(tagId = ?,true)
                and ifnull(postId = ?, true)
                and isRoot

        """
    end

    # Bind the value to the placeholder
    # Execute the query and get an iterator over the results
    results = DBInterface.execute(db, sql_query, [tag_id, post_id])

    return (SQLTalliesTree(to_detailed_tally(row), db) for row in results)
end

function insert_score_data(db::SQLite.DB, score_data::ScoreData, snapshot_timestamp::Int64)
    sql_query = """
        insert into ScoreData(
            tagId
            , parentId
            , postId
            , topNoteId
            , parentUninformedP
            , parentInformedP
            , uninformedP
            , informedP
            , count
            , total
            , selfP
            , snapshotTimestamp
        ) values (?,?,?,?,?,?,?,?,?,?,?,?)
    """

    # Bind the value to the placeholder
    # Execute the query and get an iterator over the results
    results = DBInterface.execute(
        db,
        sql_query,
        [
            score_data.tag_id,
            score_data.parent_id,
            score_data.post_id,
            score_data.top_note_effect !== nothing ?
            score_data.top_note_effect.note_id : nothing,
            score_data.effect !== nothing ? score_data.effect.uninformed_probability :
            nothing,
            score_data.effect !== nothing ? score_data.effect.informed_probability :
            nothing,
            score_data.top_note_effect !== nothing ?
            score_data.top_note_effect.uninformed_probability : nothing,
            score_data.top_note_effect !== nothing ?
            score_data.top_note_effect.informed_probability : nothing,
            score_data.self_tally.count,
            score_data.self_tally.sample_size,
            score_data.self_probability,
            snapshot_timestamp,
        ],
    )

    println("Results", results)
end
