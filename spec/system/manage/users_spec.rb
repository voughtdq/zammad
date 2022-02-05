# Copyright (C) 2012-2022 Zammad Foundation, https://zammad-foundation.org/

require 'rails_helper'

RSpec.describe 'Manage > Users', type: :system do
  describe 'switching to an alternative user', authentication_type: :form, authenticated_as: -> { original_user } do
    let(:original_user) { create(:admin) }
    let(:alternative_one_user) { create(:admin) }
    let(:alternative_two_user) { create(:admin) }

    before do
      alternative_one_user
      alternative_two_user
    end

    it 'starts as original user' do
      expect(current_user).to eq original_user
    end

    it 'switches to alternative user' do
      switch_to(alternative_one_user)
      expect(current_user).to eq alternative_one_user
    end

    it 'switches to another alternative user' do
      switch_to(alternative_one_user)
      switch_to(alternative_two_user)

      expect(current_user).to eq alternative_two_user
    end

    it 'switches back to original user' do
      switch_to(alternative_one_user)
      switch_to(alternative_two_user)

      click '.switchBackToUser-close'

      expect(current_user).to eq original_user
    end

    def switch_to(user)
      visit 'manage/users'

      within(:active_content) do
        row = find("tr[data-id=\"#{user.id}\"]")
        row.find('.js-action').click
        row.find('.js-switchTo').click
      end

      expect(page).to have_text("Zammad looks like this for \"#{user.firstname} #{user.lastname}\"")
    end
  end

  # Fixes GitHub Issue #3050 - Newly created users are only shown in the admin interface after reload
  describe 'adding a new user', authenticated_as: -> { user } do
    let(:user) { create(:admin) }

    it 'newly added user is visible in the user list' do
      visit '#manage/users'

      within(:active_content) do
        find('[data-type=new]').click

        find('[name=firstname]').fill_in with: 'NewTestUserFirstName'
        find('[name=lastname]').fill_in with: 'User'
        find('span.label-text', text: 'Customer').first(:xpath, './/..').click

        click '.js-submit'

        expect(page).to have_css('table.user-list td', text: 'NewTestUserFirstName')
      end
    end

    describe 'select an Organization' do
      before do
        create(:organization, name: 'Example Inc.', active: true)
        create(:organization, name: 'Inactive Inc.', active: false)
      end

      it 'check for inactive Organizations in Organization selection' do
        visit '#manage/users'

        within(:active_content) do
          find('[data-type=new]').click

          find('[name=organization_id] ~ .searchableSelect-main').fill_in with: '**'
          expect(page).to have_css('ul.js-optionsList > li.js-option', minimum: 2)
          expect(page).to have_css('ul.js-optionsList > li.js-option .is-inactive', count: 1)
        end
      end
    end
  end

  describe 'show/unlock a user', authenticated_as: -> { user } do
    let(:user) { create(:admin) }
    let!(:locked_user) { create(:user, login_failed: 6) }

    it 'check marked locked user and execute unlock action' do
      visit '#manage/users'

      within(:active_content) do
        row = find("tr[data-id=\"#{locked_user.id}\"]")

        expect(row).to have_css('.icon-lock')

        row.find('.js-action').click
        row.find('li.unlock').click

        expect(row).to have_no_css('.icon-lock')
      end
    end
  end

  context 'updating a user' do
    let(:user) { create(:admin) }
    let(:row)  { find 'table.user-list tbody tr', text: user.firstname }

    before do
      user

      visit '#manage/users'

      within(:active_content) do
        row.click
      end
    end

    it 'handles permission checkboxes correctly' do
      in_modal disappears: false do
        scroll_into_view 'table.settings-list'
        within 'table.settings-list tbody tr:first-child' do
          click 'input[value="full"]', visible: :all
          expect(find('input[value="full"]', visible: :all).checked?).to be true
          click 'input[value="read"]', visible: :all
          expect(find('input[value="full"]', visible: :all).checked?).to be false
          expect(find('input[value="read"]', visible: :all).checked?).to be true
          click 'input[value="full"]', visible: :all
          expect(find('input[value="full"]', visible: :all).checked?).to be true
          expect(find('input[value="read"]', visible: :all).checked?).to be false
        end
      end
    end

    it 'allows to update a user with no email/first/last/phone if login is present' do
      in_modal do
        fill_in 'firstname', with: ''
        fill_in 'lastname', with: ''
        fill_in 'Email', with: ''
        fill_in 'Phone', with: ''

        click_on 'Submit'
      end

      within :active_content do
        expect(page).to have_no_text(user.firstname)
      end
    end

    context 'when user has auto login' do
      let(:user) { create(:admin, login: "auto-#{SecureRandom.uuid}") }

      it 'does not allow to update a user with no email/first/last/phone' do
        in_modal disappears: false do
          fill_in 'firstname', with: ''
          fill_in 'lastname', with: ''
          fill_in 'Email', with: ''
          fill_in 'Phone', with: ''

          click_on 'Submit'

          expect(page).to have_text('At least one identifier')
        end
      end
    end
  end

  describe 'check user edit permissions', authenticated_as: -> { user } do

    shared_examples 'user permission' do |allow|
      it(allow ? 'allows editing' : 'forbids editing') do
        visit "#user/profile/#{record.id}"
        find('.js-action .icon-arrow-down').click
        selector = '.js-action [data-type="edit"]'
        expect(page).to(allow ? have_css(selector) : have_no_css(selector))
      end
    end

    context 'when admin tries to change admin' do
      let(:user) { create(:admin) }
      let(:record) { create(:admin) }

      include_examples 'user permission', true
    end

    context 'when admin tries to change agent' do
      let(:user) { create(:admin) }
      let(:record) { create(:agent) }

      include_examples 'user permission', true
    end

    context 'when admin tries to change customer' do
      let(:user) { create(:admin) }
      let(:record) { create(:customer) }

      include_examples 'user permission', true
    end

    context 'when agent tries to change admin' do
      let(:user) { create(:agent) }
      let(:record) { create(:admin) }

      include_examples 'user permission', false
    end

    context 'when agent tries to change agent' do
      let(:user) { create(:agent) }
      let(:record) { create(:agent) }

      include_examples 'user permission', false
    end

    context 'when agent tries to change customer' do
      let(:user) { create(:agent) }
      let(:record) { create(:customer) }

      include_examples 'user permission', true
    end

    context 'when agent tries to change customer who is also admin' do
      let(:user) { create(:agent) }
      let(:record) { create(:customer, role_ids: Role.signup_role_ids.push(Role.find_by(name: 'Admin').id)) }

      include_examples 'user permission', false
    end

    context 'when agent tries to change customer who is also agent' do
      let(:user) { create(:agent) }
      let(:record) { create(:customer, role_ids: Role.signup_role_ids.push(Role.find_by(name: 'Agent').id)) }

      include_examples 'user permission', false
    end

  end
end
