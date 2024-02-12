using SQLite


abstract type TalliesTree end

# There are no interface types in Julie, but if there were, we would define something like this
# interface TalliesTree
#     tally::DetailedTally
#     children::TalliesTree[]
# end


"""
  DetailedTally

All tallies for a post

# Fields

  * `tag_id::Int64`: The tag id.
  * `parent_id::Union{Int64, Nothing}`: The unique identifier of the parent of this post if any.
  * `post_id::Int64`: The unique identifier of this post.
  * `self::BernoulliTally`: The overall tally for this post.
  * `uninformed::BernoulliTally`: The tally for the **parent of this post** given user was not informed of this note.
  * `informed::BernoulliTally`: The tally for the **parent of this post** given user was informed of this note.
"""
Base.@kwdef struct DetailedTally
  tag_id::Int64
  parent_id::Union{Int64,Nothing}
  post_id::Int64
  self::BernoulliTally
  uninformed::BernoulliTally
  informed::BernoulliTally
end


vote_database_filename = get(ENV, "VOTE_DATABASE_PATH", nothing)

# Check if the environment variable is not set and error out
if vote_database_filename === nothing
    error("Environment variable 'VOTE_DATABASE_PATH' is not set.")
end

# Connect to the SQLite database
db = SQLite.DB(vote_database_filename)  # Replace with your database path


function toDetailedTally(result)::DetailedTally 
   # parentId = missing(result[:parentId]) ? nothing : result[:parentId]
   # println("Got result from DB", result)
   return DetailedTally(
        result[:tagId],
        result[:parentId] == 0 ? nothing : result[:parentId],
        result[:postId],
        # overall: BernoulliTally(
        #     count: result[:overallCount],
        #     total: result[:overallTotal],
        # ),

        BernoulliTally(
            something(result[:selfCount],0),
            something(result[:selfTotal],0),
        ),
        BernoulliTally(
            something(result[:uninformedCount],0),
            something(result[:uninformedTotal],0),
        ),
        BernoulliTally(
            something(result[:informedCount],0),
            something(result[:informedTotal],0),
        ),
    )
end



struct SQLTalliesTree <: TalliesTree
  tally::DetailedTally
end


# Implement `children` and `tally` to make DetailedTally implement the (theoretical) TalliesTree interface


function tally(t::SQLTalliesTree)
    # println("Getting tally")
    return t.tally
end


# Implement `children` and `tally` to make DetailedTally implement the (theoretical) TalliesTree interface
function children(t::SQLTalliesTree)
    # println("Getting children from DB")
    return getDetailedTallies(t.tally.tag_id, t.tally.post_id)
end

function tally(T::DetailedTally)
    return t.tally
end

function getDetailedTallies(tagId::Int, postId::Union{Int, Nothing})
    # Define your SQL query
    sql_query = """
        select 
            tagId
            , postId as parentId
            , noteId as postId
            , ifnull(overallCount,0) as overallCount
            , ifnull(overallTotal,0) as overallTotal
            , ifnull(uninformedCount,0) uninformedCount
            , ifnull(uninformedTotal,0) uninformedTotal
            , ifnull(informedCount,0) informedCount
            , ifnull(informedTotal,0) informedTotal
            , ifnull(noteCount,0) as selfCount
            , ifnull(noteTotal,0) as selfTotal
        from DetailedTally
        where 
            tagId = ?
            and postId = ?
    """

    if postId === nothing 
        sql_query = """
            select 
                tagId
                , 0 parentId -- Julia returns null values as 'missing', which makes no sense. It should return 'nothing'. This is our workaround.
                , postId
                , 0 as overallCount
                , 0 as oerallTotal
                , 0 as uninformedCount
                , 0 as uninformedTotal
                , 0 as informedCount
                , 0 as informedTotal
                , count as selfCount
                , total as selfTotal
            from Tally
            where 
                tagId = ?
                and ifnull(postId = ?, true)
                and isRoot

        """
    end


    # Bind the value to the placeholder
    # Execute the query and get an iterator over the results
    results = DBInterface.execute(db,sql_query, [tagId, postId])

    return ( SQLTalliesTree(toDetailedTally(row)) for row in results) 
end

