# frozen_string_literal: true

class Serializers::Api::Project < Serializers::Base
  def self.base(p)
    {
      id: p.ubid,
      name: p.name,
      credit: p.credit.to_f,
      discount: p.discount
    }
  end

  structure(:default) do |p|
    base(p)
  end
end
