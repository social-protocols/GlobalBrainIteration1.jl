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
    overall_probability =
        GLOBAL_PRIOR_UPVOTE_PROBABILITY |> (x -> update(x, tally.parent)) 
        # |> (x -> x.mean)

    uninformed_probability =
        overall_probability |>
        (x -> reset_weight(x, GLOBAL_PRIOR_UPVOTE_PROBABILITY_SAMPLE_SIZE)) |>
        (x -> update(x, tally.uninformed)) |>
        (x -> x.mean)

    informed_probability =
        GLOBAL_PRIOR_UPVOTE_PROBABILITY |>
        (x -> update(x, tally.self)) |>
        (x -> reset_weight(x, GLOBAL_PRIOR_UPVOTE_PROBABILITY_SAMPLE_SIZE)) |>
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
    if e.informed_probability == e.uninformed_probability == 0.0
        return 0.0
    end
    return e.informed_probability / (e.informed_probability + e.uninformed_probability)
end


"""
    score_posts(tallies, output_results)::Vector{NoteEffect}

Calculate (supported) scores for all post/note combinations in a thread.

# Parameters

    * `tallies`: An iteratable sequence of `TallyTree`s.
    * `output_results`: An optional function with a side effect. For example,
    it can be used to print each `ScoreData` result or store each result to a
    SQLite database.
"""
function score_posts(
    tallies::Base.Generator,
    output_results::Union{Function,Nothing} = nothing,
)::Vector{ScoreData}

    function score_post(t::TalliesTree)::Vector{ScoreData}
        subnote_score_data = score_posts(children(t), output_results)

        this_tally = tally(t)
        this_note_effect = (this_tally.parent_id === nothing) ? nothing : calc_note_effect(this_tally)
        upvote_probability =
            GLOBAL_PRIOR_UPVOTE_PROBABILITY |> (x -> update(x, this_tally.self)) |> (x -> x.mean)

        # Find the top subnote
        # TODO: the top subnote will tend to be one that hasn't received a lot of replies that reduce its support. Perhaps weigh by 
        # amount of attention received? In general, we need to deal with multiple subnotes better
        top_subnote_effect = reduce(
            (a, b) -> begin
                ma = (a === nothing) ? 0 : magnitude(a)
                mb = (b === nothing) ? 0 : magnitude(b)
                ma > mb ? a : b
            end,
            [x.effect for x in subnote_score_data if x.parent_id === this_tally.post_id];
            init = nothing,
        )

        this_note_effect_supported =
            isnothing(this_note_effect) ? nothing :
            begin
                informed_probability_supported =
                    isnothing(top_subnote_effect) ? this_note_effect.informed_probability :
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
            tag_id = this_tally.tag_id,
            parent_id = this_tally.parent_id,
            post_id = this_tally.post_id,
            effect = this_note_effect_supported,
            self_probability = upvote_probability,
            self_tally = this_tally.self,
            top_note_effect = top_subnote_effect,
        )

        if !isnothing(output_results)
            output_results([this_score_data])
        end

        return [this_score_data]

    end

    return mapreduce(score_post, vcat, tallies; init = [])
end
