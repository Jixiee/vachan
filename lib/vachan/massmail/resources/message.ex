defmodule Vachan.Massmail.Message do
  use Ash.Resource, data_layer: AshPostgres.DataLayer

  resource do
    description "Message tracks the journey of an email through the system."
  end

  postgres do
    table "messages"
    repo Vachan.Repo
  end

  code_interface do
    define_for Vachan.Massmail

    define :create, action: :create
    define :update, action: :update
    define :destroy, action: :destroy
    define :read_all, action: :read
    define :get_by_id, args: [:id], action: :by_id
  end

  actions do
    defaults [:create, :read, :update, :destroy]

    read :by_id do
      argument :id, :uuid, allow_nil?: false
      get? true
      filter expr(id == ^arg(:id))
    end
  end

  attributes do
    uuid_primary_key :id
    attribute :subject, :string, allow_nil?: false
    attribute :body, :string, allow_nil?: false
    attribute :status, :string, allow_nil?: false
  end

  relationships do
    belongs_to :campaign, Vachan.Massmail.Campaign, attribute_type: :integer

    belongs_to :receipient, Vachan.Crm.Person do
      api Vachan.Crm
    end
  end
end
