require 'rails_helper'

describe FirebaseLogsController do
  before { allow_any_instance_of(Paperclip::Attachment).to receive(:save).and_return(true) }

  let(:admin) { create :admin }
  let(:app) { FirebaseApp.find(1) }

  before do
    sign_in admin
  end

  it 'retrieves all available firebase logs' do
    get :index
    expect(assigns(:firebase_logs).first.first).to eq('registrations')
  end

  it 'destroy events' do
    allow_any_instance_of(FirebaseLogDestroyJob).to receive(:perform).and_return(nil)
    @request.env['HTTP_REFERER'] = firebase_logs_path
    delete :destroy, params: { id: 'events', type: 'all', app_id: app.id }
    expect(response).to redirect_to(firebase_logs_path(app_id: app.id))
  end
end
