module Livery
  module RSpec
    module Helper
      def presenter_receives_instance_doubles!
        before(:each) do
          allow(Livery::Presenter).to receive(:to_presenter_single) do |obj, namespace: nil|
            next nil unless obj

            klass = obj.instance_variable_get(:@doubled_module).target
            Livery::Presenter.presenterize(klass, namespace: namespace).new(obj)
          end
        end
      end
    end
  end
end
