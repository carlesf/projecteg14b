json.extract! user, :id, :about, :email, :created_at, :updated_at
json.url user_url(user, format: :json)
