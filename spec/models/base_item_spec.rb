# == Schema Information
#
# Table name: base_items
#
#  id                 :bigint           not null, primary key
#  barcode_count      :integer
#  category           :string
#  item_count         :integer
#  name               :string
#  partner_key        :string
#  reporting_category :string
#  size               :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

RSpec.describe BaseItem, type: :model do
  let(:organization) { create(:organization) }

  describe "Validations >" do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
    it { should validate_presence_of(:partner_key) }
    it { should validate_uniqueness_of(:partner_key) }
  end

  describe "Associations >" do
    it "keeps count of its associated items" do
      c = create(:base_item, name: "Base", item_count: 0)
      expect { create_list(:item, 2, base_item: c) }.to change { c.item_count }.by(2)
    end
  end

  describe "Callbacks" do
    describe "set_reporting_category" do
      it "updates the reporting_category field" do
        base_item = create(:base_item, name: "Kids S/M (38-65 lbs)")
        expect(base_item.reporting_category).to eq("disposable_diapers")

        base_item.update(name: "Liners (Incontinence)")
        expect(base_item.reporting_category).to eq("adult_incontinence")
      end

      it "sets no reporting_category for Kits" do
        base_item = create(:base_item, name: "Kit")
        expect(base_item.reporting_category).to eq(nil)
      end

      it "sets reporting_category for item names without mapping to other" do
        base_item = create(:base_item, name: "Foobar")
        expect(base_item.reporting_category).to eq("other")
      end
    end
  end

  describe "Filtering >" do
    describe '->without_kit' do
      subject { BaseItem.without_kit }

      let!(:kit_base_item) { BaseItem.find_by(name: 'Kit') }
      it 'should not include the Kit BaseItem' do
        expect(subject).not_to include(kit_base_item)
      end
    end

    describe "->by_partner_key" do
      it "shows the Base Items by partner_key" do
        create(:base_item, partner_key: "UniqueString")
        expect(BaseItem.by_partner_key("UniqueString").size).to eq(1)
        expect(BaseItem.by_partner_key("random_string").size).to eq(0)
      end
    end
  end

  describe "versioning" do
    it { is_expected.to be_versioned }
  end
end
