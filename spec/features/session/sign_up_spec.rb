feature 'sign up' do
  background do
    visit new_user_registration_path
    sync_sheet
  end
  scenario '新規登録を行う' do
    expect(User.count).to eq 0
    fill_in 'user_email', with: 'sign_up_spec@iidx12.tk'
    fill_in 'user_username', with: 'signup'
    fill_in 'user_djname', with: 'SIGNUP'
    fill_in 'user_iidxid', with: '4362-8324'
    fill_in 'user_password', with: 'hogehoge'
    fill_in 'user_password_confirmation', with: 'hogehoge'
    select '京都府', from: 'user_pref'
    select '九段', from: 'user_grade'
    click_button '登録'
    expect(User.count).to eq 1
    expect(User.exists?(email: 'sign_up_spec@iidx12.tk')).to eq 1
    expect(User.scores.count).to eq Sheet.count
  end
end
