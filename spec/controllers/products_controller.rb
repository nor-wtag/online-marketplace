# RSpec.describe ProductsController, type: :controller do
#   let(:user) { create(:user) }
#   let(:product) { create(:product, user: user) }

#   before { sign_in user }  # Sign in the user for all tests

#   describe 'GET #index' do
#     it 'assigns @products' do
#       get :index
#       expect(assigns(:products)).to include(product)
#     end
#   end

#   describe 'GET #new' do
#     it 'assigns a new product to @product' do
#       get :new
#       expect(assigns(:product)).to be_a_new(Product)
#     end
#   end

#   describe 'POST #create' do
#     context 'with valid attributes' do
#       it 'creates a new product' do
#         expect {
#           post :create, params: { product: attributes_for(:product) }
#         }.to change(Product, :count).by(1)
#       end

#       it 'redirects to the products path' do
#         post :create, params: { product: attributes_for(:product) }
#         expect(response).to redirect_to(products_path)
#         expect(flash[:notice]).to eq('Product was successfully created.')
#       end
#     end

#     context 'with invalid attributes' do
#       it 'does not create a new product' do
#         expect {
#           post :create, params: { product: attributes_for(:product, title: nil) }
#         }.not_to change(Product, :count)
#       end

#       it 're-renders the new template' do
#         post :create, params: { product: attributes_for(:product, title: nil) }
#         expect(response).to render_template(:new)
#       end
#     end
#   end

#   describe 'GET #edit' do
#     it 'assigns the requested product to @product' do
#       get :edit, params: { id: product.id }
#       expect(assigns(:product)).to eq(product)
#     end
#   end

#   describe 'PATCH #update' do
#     context 'with valid attributes' do
#       it 'updates the product' do
#         patch :update, params: { id: product.id, product: { title: 'New Title' } }
#         product.reload
#         expect(product.title).to eq('New Title')
#       end

#       it 'redirects to the products path' do
#         patch :update, params: { id: product.id, product: attributes_for(:product) }
#         expect(response).to redirect_to(products_path)
#         expect(flash[:notice]).to eq('Product was successfully updated.')
#       end
#     end

#     context 'with invalid attributes' do
#       it 'does not update the product' do
#         patch :update, params: { id: product.id, product: { title: nil } }
#         product.reload
#         expect(product.title).not_to eq(nil)
#       end

#       it 're-renders the edit template' do
#         patch :update, params: { id: product.id, product: { title: nil } }
#         expect(response).to render_template(:edit)
#       end
#     end
#   end

#   describe 'DELETE #destroy' do
#     it 'deletes the product' do
#       product  # Create the product
#       expect {
#         delete :destroy, params: { id: product.id }
#       }.to change(Product, :count).by(-1)
#     end

#     it 'redirects to the products path' do
#       delete :destroy, params: { id: product.id }
#       expect(response).to redirect_to(products_path)
#       expect(flash[:notice]).to eq('Product was successfully deleted.')
#     end
#   end
# end


# FactoryBot.define do
#   factory :product do
#     title { "Sample Product" }
#     description { "Sample description" }
#     price { 9.99 }
#     stock { 10 }
#     association :user
#   end
# end
