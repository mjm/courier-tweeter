class User < Sequel::Model(DB[:users])
  def self.register(attrs)
    id = dataset.insert_conflict(
      target: :username,
      update: attrs.reject { |k, _| k == :username }
    ).insert(attrs)
    self[id]
  end

  dataset_module do
    def lookup(username)
      where(username: username).first
    end
  end
end
