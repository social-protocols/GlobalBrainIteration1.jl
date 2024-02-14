function create_score_db(path::String)::SQLite.DB
    if ispath(path)
        @info (
            "Database already exists at this path." *
            " Returning existing database."
        )
        return SQLite.DB(path)
    end

    try
        db = SQLite.DB(path)
        SQLite.transaction(db, "DEFERRED")
        DBInterface.execute(
            db,
            """
                create table ScoreData(
                    tagId               integer
                    , parentId          integer
                    , postId            integer not null
                    , topNoteId         integer
                    , parentUninformedP real
                    , parentInformedP   real
                    , uninformedP       real
                    , informedP         real
                    , count             integer
                    , total             integer
                    , selfP             real    not null
                    , snapshotTimestamp integer not null
                ) strict
            """,
        )
        DBInterface.execute(
            db,
            """
                create table DetailedTally(
                    tagId int
                    , postId          integer not null
                    , noteId          integer not null
                    , eventType       integer
                    , informedCount   integer
                    , informedTotal   integer
                    , uninformedCount integer
                    , uninformedTotal integer
                    , overallCount    integer
                    , overallTotal    integer
                    , noteCount       integer
                    , noteTotal       integer
                ) strict
            """
        )
        DBInterface.execute(
            db,
            """
                create table Tally(
                    isRoot   integer not null
                    , tagId  integer not null
                    , postId integer not null
                    , count  integer not null
                    , total  integer not null
                    , primary key (tagId, postId)
                ) strict
            """,
        )
        DBInterface.execute(
            db,
            """
                create table InformedTally(
                    tagId       integer not null
                    , postId    integer not null
                    , noteId    integer not null
                    , eventType integer not null
                    , count     integer not null
                    , total     integer not null
                    , primary key (tagId, postId, noteId, eventType)
                ) strict
            """,
        )
        DBInterface.execute(
            db,
            """
                create table UninformedTally(
                    tagId       integer not null
                    , postId    integer not null
                    , noteId    integer not null
                    , eventType integer not null
                    , count     integer not null
                    , total     integer not null
                    , primary key (tagId, postId, noteId, eventType)
                ) strict
            """,
        )
        SQLite.commit(db)
        @info "Schema created."
        @info "Database successfully created at $path"
        return db
    catch
        if ispath(path)
            rm(path)
        end
        error(
            "Error creating database." *
            " Rolling back and deleting empty database."
        )
    end
end


function get_score_db(path::String)::SQLite.DB
    if !ispath(path)
        error("Database file does not exist: $path")
    end
    return SQLite.DB(path)
end


function to_detailed_tally(result)::DetailedTally
    # parentId = missing(result[:parentId]) ? nothing : result[:parentId]
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
)::Base.Generator
    sql_query = """
        select
            tagId
            , postId                     as parentId
            , noteId                     as postId
            , ifnull(overallCount, 0)    as parentCount
            , ifnull(overallTotal, 0)    as parentTotal
            , ifnull(uninformedCount, 0) as uninformedCount
            , ifnull(uninformedTotal, 0) as uninformedTotal
            , ifnull(informedCount, 0)   as informedCount
            , ifnull(informedTotal, 0)   as informedTotal
            , ifnull(noteCount, 0)       as selfCount
            , ifnull(noteTotal, 0)       as selfTotal
        from DetailedTally
        where ifnull(tagId = :tag_id, true)
            and postId = :post_id
    """

    if isnothing(post_id)
        sql_query = """
            select
                tagId
                , 0     as parentId 
                    -- Julia returns null values as 'missing', which makes no
                    -- sense. It should return 'nothing'. This is our workaround.
                , postId
                , 0     as parentCount
                , 0     as parentTotal
                , 0     as uninformedCount
                , 0     as uninformedTotal
                , 0     as informedCount
                , 0     as informedTotal
                , count as selfCount
                , total as selfTotal
            from Tally
            where ifnull(tagId = :tag_id, true)
                and ifnull(postId = :post_id, true)
                and isRoot
        """
    end

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
        ) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """

    results = DBInterface.execute(
        db,
        sql_query,
        [
            score_data.tag_id,
            score_data.parent_id,
            score_data.post_id,
            score_data.top_note_effect !== nothing
                ? score_data.top_note_effect.note_id
                : nothing,
            score_data.effect !== nothing
                ? score_data.effect.uninformed_probability
                : nothing,
            score_data.effect !== nothing
                ? score_data.effect.informed_probability
                : nothing,
            score_data.top_note_effect !== nothing
                ? score_data.top_note_effect.uninformed_probability
                : nothing,
            score_data.top_note_effect !== nothing
                ? score_data.top_note_effect.informed_probability
                : nothing,
            score_data.self_tally.count,
            score_data.self_tally.sample_size,
            score_data.self_probability,
            snapshot_timestamp,
        ],
    )

    println("Results", results)
end
