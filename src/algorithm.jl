"""
    magnitude(effect::Union{NoteEffect, Nothing})::Float64

Calculate the magnitude of a `NoteEffect`: the absolute difference between the
upvote probabilities given the note was shown and not shown respectively. The
effect of `Nothing` is 0.0 by definition.

# Parameters

    * `effect::Union{NoteEffect, Nothing}`: The effect to calculate the
    magnitude of.
"""
function magnitude(effect::Union{NoteEffect,Nothing})::Float64
    return abs(effect.uninformed_probability - effect.informed_probability)
end


"""
    calc_note_effect(tally::DetailedTally)::NoteEffect

Calculate the effect of a note on a post from the informed tally for the note
and the post.

# Parameters

    * `tally::DetailedTally`: The informed tallies for the note and the post.
"""
function calc_note_effect(tally::DetailedTally)::NoteEffect
    uninformed_probability =
        GLOBAL_PRIOR_UPVOTE_PROBABILITY |>
        (x -> update(x, tally.uninformed)) |>
        (x -> x.mean)

    informed_probability =
        GLOBAL_PRIOR_UPVOTE_PROBABILITY |>
        (x -> update(x, tally.uninformed)) |>
        (x -> reset_weight(x, GLOBAL_PRIOR_INFORMED_UPVOTE_PROBABILITY_SAMPLE_SIZE)) |>
        (x -> update(x, tally.informed)) |>
        (x -> x.mean)

    return NoteEffect(
        post_id = tally.parent_id,
        note_id = tally.post_id,
        uninformed_probability = uninformed_probability,
        informed_probability = informed_probability,
    )
end


"""
    calc_note_support(
        informed_probability::Float64,
        uninformed_probability::Float64
    )::Float64

Calculate the support for a note given the upvote probabilities given the note
was shown and not shown respectively.

# Parameters

    * `informed_probability::Float64`: The probability of an upvote given the
    note was shown.
    * `uninformed_probability::Float64`: The probability of an upvote given the
    note was not shown.
"""
function calc_note_support(e::NoteEffect)::Float64
    # TODO: this assert doesn't make sense conceptually -> handle p = 0 cases
    @assert(
        e.informed_probability > 0 && e.uninformed_probability > 0,
        "upvote probabilities must be positive"
    )
    return e.informed_probability / (e.informed_probability + e.uninformed_probability)
end

"""
    score_posts(tallies, output_results)::Vector{NoteEffect}

Calculate (supported) scores for all post/note combinations in a thread.

# Parameters

    * `tallies`: An interatable sequence of TallyTrees
    * `output_results`: A function to call to output each ScoreData result
"""
function score_posts(tallies, output_results)::Vector{ScoreData}
    return mapreduce(
        (t) -> begin

            tally = t.tally

            subnote_score_data = score_posts(children(t), output_results)

            this_note_effect =
                (tally.parent_id === nothing) ? nothing : calc_note_effect(tally)

            upvote_probability =
                GLOBAL_PRIOR_UPVOTE_PROBABILITY |>
                (x -> update(x, tally.self)) |>
                (x -> x.mean)

            # Find the top subnote
            # TODO: the top subnote will tend to be one that hasn't received a lot of replies that reduce its support. Perhaps weigh by 
            # amount of attention received? In general, we need to deal with multiple subnotes better
            top_subnote_effect = reduce(
                (a, b) -> begin
                    ma = (a === nothing) ? 0 : magnitude(a)
                    mb = (b === nothing) ? 0 : magnitude(b)
                    ma > mb ? a : b
                end,
                [x.effect for x in subnote_score_data if x.parent_id === tally.post_id];
                init = nothing,
            )

            this_note_effect_supported =
                isnothing(this_note_effect) ? nothing :
                begin
                    informed_probability_supported =
                        isnothing(top_subnote_effect) ?
                        this_note_effect.informed_probability :
                        begin
                            support = calc_note_support(top_subnote_effect)
                            this_note_effect.informed_probability * support +
                            this_note_effect.uninformed_probability * (1 - support)
                        end
                    something(
                        NoteEffect(
                            this_note_effect.post_id,
                            this_note_effect.note_id,
                            this_note_effect.uninformed_probability,
                            informed_probability_supported,
                        ),
                        nothing,
                    )
                end

            this_score_data = ScoreData(
                tally.tag_id,
                tally.parent_id,
                tally.post_id,
                this_note_effect_supported,
                upvote_probability,
                tally.self,
                top_subnote_effect,
            )

            output_results([this_score_data])

            return [this_score_data]
        end,
        vcat,
        tallies;
        init = [],
    )
end
