function score(score_data::ScoreData)::Float64 
	p = informed_probability(score_data)
	parentP = parent_informed_probability(score_data)
	parentQ = parent_uninformed_probability(score_data)

	return p*(1 + log2(p)) + relative_entropy(parentP, parentQ)
end

function informed_probability(score_data::ScoreData)::Float64 
	return isnothing(score_data.top_note_effect) ? score_data.self_probability : score_data.top_note_effect.informed_probability
end

function uninformed_probability(score_data::ScoreData)::Float64 
	return isnothing(score_data.top_note_effect) ? score_data.self_probability : score_data.top_note_effect.uninformed_probability
end

function parent_informed_probability(score_data::ScoreData)::Float64 
	return isnothing(score_data.effect) ? score_data.self_probability : score_data.effect.informed_probability
end

function parent_uninformed_probability(score_data::ScoreData)::Float64 
	return isnothing(score_data.effect) ? score_data.self_probability : score_data.effect.uninformed_probability
end

function top_note_id(score_data::ScoreData)::Union{Int64,Nothing} 
	return !isnothing(score_data.top_note_effect) ? score_data.top_note_effect.note_id : nothing
end