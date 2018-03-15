require 'test_helper'

class ChefsEditTest < ActionDispatch::IntegrationTest
  def setup
    @chef = Chef.create!(chefname: "Caruba", email:"caruba@example.com",
      password: "password", password_confirmation: "password")
    @chef2 = Chef.create!(chefname: "John", email:"john@example.com",
      password: "password", password_confirmation: "password")
    @admin_chef = Chef.create!(chefname: "Admin", email:"admin@example.com",
      password: "password", password_confirmation: "password", admin: true)
  end

  test 'reject an invalid edit' do
    sign_in_as(@chef, 'password')
    get edit_chef_path(@chef)
    assert_template 'chefs/edit'
    patch chef_path(@chef), params: { chef: { chefname: ' ', email: 'caruba@example.com' } }
    assert_template 'chefs/edit'
    assert_select 'h2.panel-title'
    assert_select 'div.panel-body'
  end

  test 'accept valid edit' do
    sign_in_as(@chef, 'password')
    get edit_chef_path(@chef)
    assert_template 'chefs/edit'
    patch chef_path(@chef), params: { chef: { chefname: 'caruba1', email: 'caruba1@example.com' } }
    assert_redirected_to @chef
    assert_not flash.empty?
    @chef.reload
    assert_match "caruba1", @chef.chefname
    assert_match "caruba1@example.com", @chef.email
  end

  test 'accept edit attempt by admin user' do
    sign_in_as(@admin_chef, 'password')
    get edit_chef_path(@chef)
    assert_template 'chefs/edit'
    patch chef_path(@chef), params: { chef: { chefname: 'caruba3', email: 'caruba3@example.com' } }
    assert_redirected_to @chef
    assert_not flash.empty?
    @chef.reload
    assert_match "caruba3", @chef.chefname
    assert_match "caruba3@example.com", @chef.email
  end

  test 'redirect edit attempt by another non-admin user' do
    sign_in_as(@chef2, 'password')
    update_name = 'John'
    update_email = 'john@example.com'
    patch chef_path(@chef), params: { chef: { chefname: update_name, email: update_email } }
    assert_redirected_to chefs_path
    assert_not flash.empty?
    @chef.reload
    assert_match "Caruba", @chef.chefname
    assert_match "caruba@example.com", @chef.email
  end

end
