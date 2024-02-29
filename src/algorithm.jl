
"""
    score_tree(
        tallies::Base.Generator,
        output_results::Union{Function,Nothing} = nothing,
    )::Vector{ScoreData}

Score a tree of tallies.

# Parameters

    * `tallies::Base.Generator`: A `Base.Generator` of `SQLTalliesTree`s.
    * `output_results::Union{Function,Nothing}`: A function to output the results. If
      `nothing`, no output is produced. This function can be used for side effects, such as
      writing to a database.
"""
function score_tree(
    tallies::Vector{TalliesTree},
    output_results::Union{Function,Nothing} = nothing,
)::Vector{ScoreData}
    function score_subtree(t::TalliesTree)::Vector{ScoreData}


        this_tally = t.tally()

        if !t.needs_recalculation()
            # @info "Using existing score data for $(this_tally.post_id)"
            return [t.score_data()]
        else 
            # @info "Calculating score for $(this_tally.post_id)"
        end

        subnote_score_data = score_tree(t.children(), output_results)

            # println("Subnote score data for $(this_tally.post_id): $subnote_score_data")


        this_note_effect =
            isnothing(this_tally.parent_id) ? nothing : calc_note_effect(this_tally)
        upvote_probability =
            GLOBAL_PRIOR_UPVOTE_PROBABILITY |>
            (x -> update(x, this_tally.overall)) |>
            (x -> x.mean)

        # Find the top subnote
        # TODO: The top subnote will tend to be one that hasn't received a lot of replies
        #       that reduce its support. Perhaps weigh by amount of attention received? In
        #       general, we need to deal with multiple subnotes better.
        top_subnote_effect = reduce(
            (a, b) -> begin
                ma = isnothing(a) ? 0 : magnitude(a)
                mb = isnothing(b) ? 0 : magnitude(b)
                # TODO: Do we need a tie-breaker here?
                ma > mb ? a : b
            end,
            [x.effect for x in subnote_score_data if x.parent_id == this_tally.post_id];
            init = nothing,
        )

        this_note_effect_supported = if isnothing(this_note_effect)
            nothing
        else
            informed_probability_supported = if isnothing(top_subnote_effect)
                this_note_effect.informed_probability
            else
                supp = calc_note_support(top_subnote_effect)
                this_note_effect.informed_probability * supp +
                this_note_effect.uninformed_probability * (1 - supp)
            end
            something(
                NoteEffect(
                    post_id = this_note_effect.post_id,
                    note_id = this_note_effect.note_id,
                    informed_probability = informed_probability_supported,
                    uninformed_probability = this_note_effect.uninformed_probability,
                    # informed_tally = this_tally.informed,
                    # uninformed_tally = this_tally.uninformed,
                ),
                nothing,
            )
        end

        this_score_data = ScoreData(
            tag_id = this_tally.tag_id,
            parent_id = this_tally.parent_id,
            post_id = this_tally.post_id,
            effect = this_note_effect_supported,
            overall_probability = upvote_probability,
            overall_tally = this_tally.overall,
            top_note_effect = top_subnote_effect,
        )

        if !isnothing(output_results)
            output_results([this_score_data])
        end

        # println("Returning score data for $(this_tally.post_id): $this_score_data")
        return [this_score_data]
    end

    return mapreduce(score_subtree, vcat, tallies; init = [])
end

