"""
    create_score_db_tables(path::String)::Nothing

Create a score database with the required schema. If a database already exists at the
provided path, the tables will be created if they don't already exist.
"""
function create_score_db_tables(path::String)::Nothing
    try
        db = SQLite.DB(path)
        SQLite.transaction(db, "DEFERRED")
        DBInterface.execute(
            db,
            """
                create table if not exists ScoreData(
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
                create table if not exists DetailedTally(
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
            """,
        )
        DBInterface.execute(
            db,
            """
                create table if not exists Tally(
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
                create table if not exists InformedTally(
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
                create table if not exists UninformedTally(
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
    catch
        error("Error creating tables. Rolling back.")
    end
end


"""
    get_score_db(path::String)::SQLite.DB

Get a connection to the score database at the provided path. If the database does not
exist, an error will be thrown.
"""
function get_score_db(path::String)::SQLite.DB
    if !ispath(path)
        error("Database file does not exist: $path")
    end
    return SQLite.DB(path)
end


"""
    to_detailed_tally(result::SQLite.Row)::DetailedTally

Convert a SQLite result row to a `DetailedTally`.
"""
function to_detailed_tally(result::SQLite.Row)::DetailedTally
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


"""
    get_detailed_tallies(
        db::SQLite.DB,
        tag_id::Union{Int,Nothing},
        post_id::Union{Int,Nothing},
    )::Base.Generator

Get the detailed tallies for a given tag and post. If `tag_id` is `nothing`, tallies for
all tags will be returned. If `post_id` is `nothing`, tallies for all posts will be
returned. If both `tag_id` and `post_id` are `nothing`, all tallies will be returned.
The function returns a generator of `SQLTalliesTree`s.
"""
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
                        -- Julia returns null values as 'missing', which makes
                        -- no sense. It should return 'nothing'. This is our
                        -- workaround.
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


"""
    insert_score_data(
        db::SQLite.DB,
        score_data::ScoreData,
        snapshot_timestamp::Int64,
    )::Nothing

Insert a `ScoreData` instance into the score database.
"""
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

    DBInterface.execute(
        db,
        sql_query,
        [
            score_data.tag_id,
            score_data.parent_id,
            score_data.post_id,
            score_data.top_note_effect !== nothing ? score_data.top_note_effect.note_id :
            nothing,
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
end
