RSpec.describe User do
  describe 'registering a user' do
    let(:attributes) do
      {
        username: 'jappleseed',
        name: 'John Appleseed',
        access_token: 'foo',
        access_token_secret: 'foobar'
      }
    end

    context 'when the user does not exist' do
      it 'creates the new user' do
        User.register(attributes)
        expect(User.first).to have_attributes(attributes)
      end

      it 'returns the created user' do
        result = User.register(attributes)
        expect(result).to be_a User
        expect(result.id).to be_truthy
      end
    end

    context 'when the user already exists' do
      let(:new_attributes) do
        attributes.merge(
          name: 'Jane Appleseed',
          access_token: 'bar',
          access_token_secret: 'baz'
        )
      end

      before do
        User.register(attributes)
      end

      it 'updates the attributes of the user' do
        User.register(new_attributes)
        expect(User.count).to be 1
        expect(User.first).to have_attributes(new_attributes)
      end
    end
  end

  describe 'looking up a user by username' do
    let(:found_user) { User.lookup('example') }

    context 'when the user does not exist' do
      it 'returns nil' do
        expect(found_user).to be_nil
      end
    end

    context 'when the user exists' do
      let(:registered_user) do
        User.register username: 'example', name: 'Example'
      end

      before { registered_user }

      it 'returns the user' do
        expect(found_user).to eq registered_user
      end
    end
  end
end
