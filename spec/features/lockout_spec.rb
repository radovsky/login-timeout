require 'spec_helper'

feature 'Sign Up' do
  before :each do
    visit "/users/new"
  end
  
  it 'visits signup page' do
    expect(page).to have_content 'Create Account'
  end
  
  it 'creates a user' do
    fill_in 'user[username]', with: 'test_user'
    fill_in 'user[password]', with: 'password'
    click_button 'Create Account'
    expect(page).to have_content 'Welcome, test_user!'
  end
end

feature 'Sign Out' do
  it 'logs out' do
    visit '/users/new'
    fill_in 'user[username]', with: 'test_user'
    fill_in 'user[password]', with: 'password'
    click_button 'Create Account'
    expect(page).to have_content 'Welcome, test_user!'
    click_button 'Sign Out'
    expect(page).to have_content 'Create Account'
  end
end

feature 'Sign In' do
  before :each do
    sign_up_and_go_to_login
  end
  
  it 'signs in successfully' do
    fill_in 'user[username]', with: 'test_user'
    fill_in 'user[password]', with: 'password'
    click_button 'Sign In'
    expect(page).to have_content 'Welcome, test_user!'
  end
  
  it 'tries wrong username' do
    fill_in 'user[username]', with: 'someguy'
    fill_in 'user[password]', with: 'somepassword'
    click_button 'Sign In'
    expect(page).to have_content 'Username and/or password is invalid.'
  end
  
  it 'tries wrong password multiple times' do
    attempt_login_wrong_password
    expect(page).to have_content 'Incorrect password. You will be locked out after 2 more unsuccessful attempts.'
    
    attempt_login_wrong_password
    expect(page).to have_content 'Incorrect password. You will be locked out after 1 more unsuccessful attempts.'
  
    attempt_login_wrong_password
    expect(page).to have_content 'You are locked out, test_user. Try again in 10 minutes.'
  end
end