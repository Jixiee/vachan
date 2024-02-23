defmodule Vachan.Repo.Migrations.CrmAndMail do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create table(:templates, primary_key: false) do
      add :id, :bigserial, null: false, primary_key: true
      add :name, :text, null: false
      add :subject, :text, null: false
      add :text_body, :text, null: false
      add :html_body, :text, null: false
      add :campaign_id, :uuid
    end

    create table(:people, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("uuid_generate_v4()"), primary_key: true
      add :first_name, :text, null: false
      add :last_name, :text, null: false
      add :email, :citext, null: false
      add :phone, :text
      add :city, :text
      add :state, :text
      add :country, :text
      add :designation, :text
      add :company, :text
      add :tags, :text
    end

    create unique_index(:people, [:email], name: "people_unique_email_index")

    create table(:messages, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("uuid_generate_v4()"), primary_key: true
      add :subject, :text, null: false
      add :body, :text, null: false
      add :status, :text, null: false
      add :campaign_id, :uuid
      add :receipient_id, :uuid
    end

    create table(:massmail_events, primary_key: false) do
      add :id, :bigserial, null: false, primary_key: true
      add :type, :text, null: false
      add :created_at, :utc_datetime_usec, null: false, default: fragment("now()")

      add :message_id,
          references(:messages,
            column: :id,
            name: "massmail_events_message_id_fkey",
            type: :uuid,
            prefix: "public"
          )
    end

    create table(:crm_people_lists, primary_key: false) do
      add :person_id,
          references(:people,
            column: :id,
            name: "crm_people_lists_person_id_fkey",
            type: :uuid,
            prefix: "public"
          ),
          primary_key: true,
          null: false

      add :list_id, :uuid, null: false, primary_key: true
    end

    create table(:crm_lists, primary_key: false) do
      add :id, :bigserial, null: false, primary_key: true
    end

    alter table(:crm_people_lists) do
      modify :list_id,
             references(:crm_lists,
               column: :id,
               name: "crm_people_lists_list_id_fkey",
               type: :bigserial,
               prefix: "public"
             )
    end

    alter table(:crm_lists) do
      add :name, :text, null: false
    end

    create table(:campaigns, primary_key: false) do
      add :id, :bigserial, null: false, primary_key: true
    end

    alter table(:templates) do
      modify :campaign_id,
             references(:campaigns,
               column: :id,
               name: "templates_campaign_id_fkey",
               type: :uuid,
               prefix: "public"
             )
    end

    alter table(:messages) do
      modify :campaign_id,
             references(:campaigns,
               column: :id,
               name: "messages_campaign_id_fkey",
               type: :uuid,
               prefix: "public"
             )

      modify :receipient_id,
             references(:people,
               column: :id,
               name: "messages_receipient_id_fkey",
               type: :uuid,
               prefix: "public"
             )
    end

    alter table(:campaigns) do
      add :name, :text, null: false

      add :list_id,
          references(:crm_lists,
            column: :id,
            name: "campaigns_list_id_fkey",
            type: :uuid,
            prefix: "public"
          )
    end
  end

  def down do
    drop constraint(:campaigns, "campaigns_list_id_fkey")

    alter table(:campaigns) do
      remove :list_id
      remove :name
    end

    drop constraint(:messages, "messages_campaign_id_fkey")

    drop constraint(:messages, "messages_receipient_id_fkey")

    alter table(:messages) do
      modify :receipient_id, :uuid
      modify :campaign_id, :uuid
    end

    drop constraint(:templates, "templates_campaign_id_fkey")

    alter table(:templates) do
      modify :campaign_id, :uuid
    end

    drop table(:campaigns)

    alter table(:crm_lists) do
      remove :name
    end

    drop constraint(:crm_people_lists, "crm_people_lists_list_id_fkey")

    alter table(:crm_people_lists) do
      modify :list_id, :uuid
    end

    drop table(:crm_lists)

    drop constraint(:crm_people_lists, "crm_people_lists_person_id_fkey")

    drop table(:crm_people_lists)

    drop constraint(:massmail_events, "massmail_events_message_id_fkey")

    drop table(:massmail_events)

    drop table(:messages)

    drop_if_exists unique_index(:people, [:email], name: "people_unique_email_index")

    drop table(:people)

    drop table(:templates)
  end
end
