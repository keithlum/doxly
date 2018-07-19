json.array!(@document_signers) do |document_signer|
  json.extract! document_signer, :id, :document_id, :user_id, :signed, :signed_at
  json.url document_signer_url(document_signer, format: :json)
end
