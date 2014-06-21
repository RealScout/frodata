require 'spec_helper'

describe OData::Property do
  let(:subject) { OData::Property.new('PropertyName', '1') }
  let(:good_comparison) { OData::Property.new('GoodComparison', '1') }
  let(:bad_comparison) { OData::Property.new('BadComparison', '2') }

  it { expect(subject).to respond_to(:name) }
  it { expect(subject.name).to eq('PropertyName') }

  it { expect(subject).to respond_to(:value) }
  it { expect(subject.value).to eq('1') }

  it { expect(subject).to respond_to(:type) }
  it { expect(lambda {subject.type}).to raise_error(NotImplementedError) }

  it { expect(subject).to respond_to(:allows_nil?) }
  it { expect(subject.allows_nil?).to eq(true) }

  it { expect(subject).to respond_to(:max_length) }
  it { expect(lambda {subject.max_length}).to raise_error(NotImplementedError) }
  #it { expect(subject.max_length).to eq(nil) }

  it { expect(subject).to respond_to(:fixed_length) }
  it { expect(lambda {subject.fixed_length}).to raise_error(NotImplementedError) }
  #it { expect(subject.fixed_length).to eq(nil) }

  it { expect(subject).to respond_to(:precision) }
  it { expect(lambda {subject.precision}).to raise_error(NotImplementedError) }
  #it { expect(subject.precision).to eq(nil) }

  it { expect(subject).to respond_to(:scale) }
  it { expect(lambda {subject.scale}).to raise_error(NotImplementedError) }
  #it { expect(subject.scale).to eq(nil) }

  it { expect(subject).to respond_to(:is_unicode?) }
  it { expect(lambda {subject.is_unicode?}).to raise_error(NotImplementedError) }
  #it { expect(subject.is_unicode?).to eq(true) }

  it { expect(subject).to respond_to(:collation) }
  it { expect(lambda {subject.collation}).to raise_error(NotImplementedError) }
  #it { expect(subject.collation).to eq(nil) }

  it { expect(subject).to respond_to(:srid) }
  it { expect(lambda {subject.srid}).to raise_error(NotImplementedError) }
  #it { expect(subject.srid).to eq(0) }

  it { expect(subject).to respond_to(:default_value) }
  it { expect(lambda {subject.default_value}).to raise_error(NotImplementedError) }
  #it { expect(subject.default_value).to eq(nil) }

  it { expect(subject).to respond_to(:concurrency_mode) }
  it { expect(subject.concurrency_mode).to eq(:none) }

  it { expect(subject).to respond_to(:==) }
  it { expect(subject == good_comparison).to eq(true) }
  it { expect(subject == bad_comparison).to eq(false) }
end