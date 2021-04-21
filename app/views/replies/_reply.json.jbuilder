json.extract! reply, :id, :content, :user_id, :commentreply_id, :created_at, :updated_at
json.url reply_url(reply, format: :json)
