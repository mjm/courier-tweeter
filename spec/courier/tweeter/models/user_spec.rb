RSpec.describe Courier::Tweeter::User do
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
        Courier::Tweeter::User.register(attributes)
        expect(Courier::Tweeter::User.first).to have_attributes(attributes)
      end

      it 'returns the created user' do
        result = Courier::Tweeter::User.register(attributes)
        expect(result).to be_a Courier::Tweeter::User
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
        Courier::Tweeter::User.register(attributes)
      end

      it 'updates the attributes of the user' do
        Courier::Tweeter::User.register(new_attributes)
        expect(Courier::Tweeter::User.count).to be 1
        expect(Courier::Tweeter::User.first).to have_attributes(new_attributes)
      end
    end
  end
end
