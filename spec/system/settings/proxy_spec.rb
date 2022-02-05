# Copyright (C) 2012-2022 Zammad Foundation, https://zammad-foundation.org/

require 'rails_helper'

RSpec.describe 'Manage > Settings > System > Network', type: :system do

  before { visit 'settings/system' }

  let(:proxy) { ENV['ZAMMAD_PROXY'] }
  let(:proxy_username) { ENV['ZAMMAD_PROXY_USERNAME'] }
  let(:proxy_password) { ENV['ZAMMAD_PROXY_PASSWORD'] }

  describe 'configure proxy setting' do

    it 'test proxy settings with correct config' do

      within(:active_content) do
        click(:href, '#network')

        fill_in 'proxy',            with: proxy
        fill_in 'proxy_username',   with: proxy_username
        fill_in 'proxy_password',   with: proxy_password
        click_on 'Test Connection'

        expect(page).to have_button('Test Connection', visible: :hidden)
        expect(page).to have_button('Submit', visible: :visible)

        find('.js-submit:not(.hide)').click

        expect(page).to have_button('Submit', visible: :hidden)
        expect(page).to have_button('Test Connection', visible: :visible)
      end
    end

    context 'test proxy settings when invalid config is used' do

      it 'with invalid proxy' do

        within(:active_content) do
          click(:href, '#network')

          fill_in 'proxy',            with: 'invalid_proxy'
          fill_in 'proxy_username',   with: proxy_username
          fill_in 'proxy_password',   with: proxy_password
          click_on 'Test Connection'

          expect(page).to have_css('h1.modal-title', text: 'Error')
          expect(page).to have_css('div.modal-body', text: %r{Invalid proxy address})
          expect(page).to have_button('Test Connection', visible: :visible)
          expect(page).to have_button('Submit', visible: :hidden)

        end
      end

      it 'with unknown proxy' do

        within(:active_content) do
          click(:href, '#network')

          fill_in 'proxy',            with: 'proxy.example.com:3128'
          fill_in 'proxy_username',   with: proxy_username
          fill_in 'proxy_password',   with: proxy_password
          click_on 'Test Connection'

          expect(page).to have_css('h1.modal-title', text: 'Error')
          expect(page).to have_css('div.modal-body', text: %r{Failed to open TCP connection})
          expect(page).to have_button('Test Connection', visible: :visible)
          expect(page).to have_button('Submit', visible: :hidden)

        end
      end

      it 'with invalid proxy username' do

        within(:active_content) do
          click(:href, '#network')

          fill_in 'proxy',            with: proxy
          fill_in 'proxy_username',   with: 'invalid_username'
          fill_in 'proxy_password',   with: proxy_password
          click_on 'Test Connection'

          expect(page).to have_css('h1.modal-title', text: 'Error')
          expect(page).to have_css('div.modal-body', text: %r{Access Denied})
          expect(page).to have_button('Test Connection', visible: :visible)
          expect(page).to have_button('Submit', visible: :hidden)

        end
      end

      it 'with invalid proxy password' do

        within(:active_content) do
          click(:href, '#network')

          fill_in 'proxy',            with: proxy
          fill_in 'proxy_username',   with: proxy_username
          fill_in 'proxy_password',   with: 'invalid_password'
          click_on 'Test Connection'

          expect(page).to have_css('h1.modal-title', text: 'Error')
          expect(page).to have_css('div.modal-body', text: %r{Access Denied})
          expect(page).to have_button('Test Connection', visible: :visible)
          expect(page).to have_button('Submit', visible: :hidden)

        end
      end
    end

  end
end
