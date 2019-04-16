defmodule SocializerWeb.Schema.MessageTypes do
  use Absinthe.Schema.Notation
  use Absinthe.Ecto, repo: Socializer.Repo

  alias SocializerWeb.Resolvers

  @desc "A message on the site"
  object :message do
    field :id, :id
    field :body, :string

    field :conversation, :conversation, resolve: assoc(:conversation)
    field :user, :user, resolve: assoc(:user)
  end

  object :message_queries do
    @desc "Get all messages for a conversation"
    field :messages, list_of(:message) do
      arg(:conversation_id, non_null(:id))
      resolve(&Resolvers.MessageResolver.list/3)
    end
  end

  object :message_mutations do
    @desc "Create message"
    field :create_message, :message do
      arg(:conversation_id, non_null(:id))
      arg(:body, non_null(:string))

      resolve(&Resolvers.MessageResolver.create/3)
    end
  end

  object :message_subscriptions do
    field :message_created, :message do
      arg(:conversation_id, non_null(:id))

      config(fn args, _ ->
        {:ok, topic: args.conversation_id}
      end)

      trigger(:create_message,
        topic: fn message ->
          message.conversation_id
        end
      )
    end
  end
end
