json.extract! vote, :id, :votable_id, :votable_type, :voter_id, :created_at, :updated_at
json.url vote_url(vote, format: :json)
