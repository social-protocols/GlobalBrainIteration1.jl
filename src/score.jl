function score(score_data::ScoreData)::Float64 
	p = informed_probability(score_data)
	parentP = parent_informed_probability(score_data)
	parentQ = parent_uninformed_probability(score_data)

	return p*(1 + log2(p)) + (isnothing(score_data.effect) ? 0 : relative_entropy(parentP, parentQ))
end

function informed_probability(score_data::ScoreData)::Float64 
	return isnothing(score_data.top_note_effect) ? score_data.overall_probability : score_data.top_note_effect.informed_probability
end

function uninformed_probability(score_data::ScoreData)::Float64 
	return isnothing(score_data.top_note_effect) ? score_data.overall_probability : score_data.top_note_effect.uninformed_probability
end

function parent_informed_probability(score_data::ScoreData)::Union{Float64,Nothing} 
	return isnothing(score_data.effect) ? nothing : score_data.effect.informed_probability
end

function parent_uninformed_probability(score_data::ScoreData)::Union{Float64,Nothing} 
	return isnothing(score_data.effect) ? nothing : score_data.effect.uninformed_probability
end

function top_note_id(score_data::ScoreData)::Union{Int64,Nothing} 
	return !isnothing(score_data.top_note_effect) ? score_data.top_note_effect.note_id : nothing
end

function informed_tally(score_data::ScoreData)::Tally 
	return isnothing(score_data.top_note_effect) ? score_data.overall_tally : score_data.top_note_effect.informed_tally
end

function uninformed_tally(score_data::ScoreData)::Tally 
	return isnothing(score_data.top_note_effect) ? score_data.overall_tally : score_data.top_note_effect.uninformed_tally
end

function parent_p_sample_size(score_data::ScoreData)::Union{Int64,Nothing} 
		return isnothing(score_data.effect) ? nothing : score_data.effect.informed_sample_size
end

function parent_q_sample_size(score_data::ScoreData)::Union{Int64,Nothing} 
		return isnothing(score_data.effect) ? nothing : score_data.effect.uninformed_sample_size
end

function p_sample_size(score_data::ScoreData)::Int64 
	return isnothing(score_data.top_note_effect) ? 0 : score_data.top_note_effect.informed_sample_size
end

function q_sample_size(score_data::ScoreData)::Int64 
	return isnothing(score_data.top_note_effect) ? score_data.overall_tally.sample_size : score_data.top_note_effect.uninformed_sample_size
end

