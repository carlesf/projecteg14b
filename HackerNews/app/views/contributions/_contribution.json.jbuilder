json.extract! contribution, :id, :title, :url, :text, :created_at, :updated_at
json.url contribution_url(contribution, format: :json)
