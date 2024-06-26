defmodule Vachan.Accounts.Token do
  use Ash.Resource,
    domain: Vachan.Accounts,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication.TokenResource]

  token do
    domain(Vachan.Accounts)
  end

  postgres do
    table "tokens"
    repo Vachan.Repo
  end

  # If using policies, add the following bypass:
  # policies do
  #   bypass AshAuthentication.Checks.AshAuthenticationInteraction do
  #     authorize_if always()
  #   end
  # end
end
