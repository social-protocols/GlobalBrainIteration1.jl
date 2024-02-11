using SQLite

# Define the Post type
struct DetailedTally
    parentId::Union{Int,Missing}
    postId::Union{Int,Missing}
    uninformedCount::Union{Int,Missing}
    uninformedTotal::Union{Int,Missing}
    informedCount::Union{Int,Missing}
    informedTotal::Union{Int,Missing}
    selfCount::Union{Int,Missing}
    selfTotal::Union{Int,Missing}
end


vote_database_filename = get(ENV, "VOTE_DATABASE_PATH", nothing)

# Check if the environment variable is not set and error out
if vote_database_filename === nothing
    error("Environment variable 'VOTE_DATABASE_PATH' is not set.")
end

# Connect to the SQLite database
db = SQLite.DB(vote_database_filename)  # Replace with your database path

function getDetailedTallies(tagId::Int)

    # Define your SQL query
    sql_query = """
        with recursive depth_first_traversal(postId, parentId, tagId) as (
            select t.postId, null, t.tagId
            from tally t
            left join detailedTally dt on (t.postId = dt.noteId and t.tagId = dt.tagId) 
            where 
                t.tagId = ?
                and dt.noteId is null
            
            union

            select dt.noteId, dt.postId, dt.tagId
            from detailedTally dt
            inner join depth_first_traversal dft on dt.postId = dft.postId and dt.tagId = dft.tagId
        )

        select 
            dft.parentId
            , dft.postId
            , ifnull(overallCount, 0) as overallCount
            , ifnull(overallTotal, 0) as overallTotal
            , ifnull(uninformedCount,0) uninformedCount
            , ifnull(uninformedTotal,0) uninformedTotal
            , ifnull(informedCount,0) informedCount
            , ifnull(informedTotal,0) informedTotal
            , ifnull(noteCount,0) as selfCount
            , ifnull(noteTotal,0) as selfTotal
        from depth_first_traversal dft
        left join detailedTally t on (dft.parentId = t.postId and dft.postId = t.noteId)
        limit 20;
    """


    # Bind the value to the placeholder
    # Execute the query and get an iterator over the results
    results = DBInterface.execute(db,sql_query, [tagId])

    # for row in results
    #     println(row)
    # end

    # Create a new iterator with DetailedTally type


    return results
end

results = getDetailedTallies(3)

tallies = (
    DetailedTally(
        row[:parentId],
        row[:postId],
        row[:uninformedCount],
        row[:uninformedTotal],
        row[:informedCount],
        row[:informedTotal],
        row[:selfCount],
        row[:selfTotal]
    ) for row in results
)

using DataFrames

DataFrame(results)

for row in tallies
    println(row)
end


# Close the database connection
SQLite.close!(db)
