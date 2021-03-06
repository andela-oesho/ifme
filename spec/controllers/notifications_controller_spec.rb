RSpec.describe NotificationsController, type: :controller do
  describe '#clear' do
    let(:user) { FactoryGirl.create(:user1) }
    let(:other_user) { FactoryGirl.create(:user2) }
    let!(:other_user_notification) do
      FactoryGirl.create(:notification, user: other_user)
    end

    context 'when the user is signed in' do
      before do
        allow(controller).to receive(:current_user).and_return(user)
      end

      context 'when the user has notifications' do
        let!(:notification) do
          FactoryGirl.create(:notification, user: user)
        end

        let!(:notification_two) do
          FactoryGirl.create(:notification, user: user)
        end

        it 'deletes all notifications belonging to the current user' do
          expect(Notification.where(userid: user.id).count).to eq(2)

          delete :clear
          expect(Notification.where(userid: user.id).count).to eq(0)
        end

        it 'does not delete notifications belonging to other users' do
          expect(Notification.where(userid: other_user.id).count).to eq(1)

          delete :clear
          expect(Notification.where(userid: other_user.id).count).to eq(1)
        end
      end

      context 'when the user does not have notifications' do
        it 'does does not delete any notifications' do
          delete :clear
          expect(Notification.where(userid: user.id)).to be_empty
        end
      end

      it 'renders nothing' do
        delete :clear
        expect(response).to have_http_status 200
        expect(response.body).to be_empty
      end
    end

    context 'when the user is not signed in' do
      before do
        allow(controller).to receive(:user_signed_in?).and_return(false)

        delete :clear, format: format
      end

      context 'and the requested format is html' do
        let(:format) { 'html' }

        it 'redirects to the new_user_session_path' do
          expect(response).to redirect_to new_user_session_path
        end
      end

      context 'and the requested format is json' do
        let(:format) { 'json' }

        it 'renders a HEAD response with :no_content' do
          expect(response).to have_http_status 204
        end
      end
    end
  end
end
