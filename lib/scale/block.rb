module Scale
  module Types

    class Extrinsic
      include SingleValue
      # attr_accessor :address, :signature, :nonce, :era, :extrinsic_hash, :call_index, :params_raw, :params

      def self.generate_hash(data)
        Blake2b.hex data, Blake2b::Key.none, 32
      end

      def self.decode(scale_bytes, metadata)
        result = {}

        extrinsic_length = Compact.decode(scale_bytes).value
        # TODO: legacy version

        version_info = scale_bytes.get_next_bytes(1).bytes_to_hex
        contains_transaction = version_info.to_i(16) >= 80

        if version_info == "0x01" || version_info == "0x81"

          if contains_transaction
            address = Scale::Types.get("Address").decode(scale_bytes)
            result[:address] = address.value
            result[:account_length] = address.account_length
            result[:account_id] = address.account_id
            result[:account_index] = address.account_index
            result[:signature] = Scale::Types.get("Signature").decode(scale_bytes).value
            result[:nonce] = Scale::Types.get("Compact").decode(scale_bytes).value
            result[:era] = Scale::Types.get("Era").decode(scale_bytes).value
            result[:extrinsic_hash] = generate_hash(scale_bytes.bytes)
          end
          result[:call_index] = scale_bytes.get_next_bytes(2).bytes_to_hex[2..]

        elsif version_info == "0x02" || version_info == "0x82"

          if contains_transaction
            address = Scale::Types.get("Address").decode(scale_bytes)
            result[:address] = address.value
            result[:account_length] = address.account_length
            result[:account_id] = address.account_id
            result[:account_index] = address.account_index
            result[:signature] = Scale::Types.get("Signature").decode(scale_bytes).value
            result[:era] = Scale::Types.get("Era").decode(scale_bytes).value
            result[:nonce] = Scale::Types.get("Compact").decode(scale_bytes).value
            result[:tip] = Scale::Types.get("Compact").decode(scale_bytes).value
            result[:extrinsic_hash] = generate_hash(scale_bytes.bytes)
          end
          result[:call_index] = scale_bytes.get_next_bytes(2).bytes_to_hex[2..]

        elsif version_info == "0x03" || version_info == "0x83"

          if contains_transaction
            address = Scale::Types.get("Address").decode(scale_bytes)
            result[:address] = address.value
            result[:account_length] = address.account_length
            result[:account_id] = address.account_id
            result[:account_index] = address.account_index
            result[:signature] = Scale::Types.get("Signature").decode(scale_bytes).value
            result[:era] = Scale::Types.get("Era").decode(scale_bytes).value
            result[:nonce] = Scale::Types.get("Compact").decode(scale_bytes).value
            result[:tip] = Scale::Types.get("Compact").decode(scale_bytes).value
            result[:extrinsic_hash] = generate_hash(scale_bytes.bytes)
          end
          result[:call_index] = scale_bytes.get_next_bytes(2).bytes_to_hex[2..]

        elsif version_info == "0x04" || version_info == "0x84"

          if contains_transaction
            address = Scale::Types.get("Address").decode(scale_bytes)
            result[:address] = address.value
            result[:account_length] = address.account_length
            result[:account_id] = address.account_id
            result[:account_index] = address.account_index
            result[:signature_version] = Scale::Types.get("U8").decode(scale_bytes).value
            result[:signature] = Scale::Types.get("Signature").decode(scale_bytes).value
            result[:era] = Scale::Types.get("Era").decode(scale_bytes).value
            result[:nonce] = Scale::Types.get("Compact").decode(scale_bytes).value
            result[:tip] = Scale::Types.get("Compact").decode(scale_bytes).value
            result[:extrinsic_hash] = generate_hash(scale_bytes.bytes)
          end
          result[:call_index] = scale_bytes.get_next_bytes(2).bytes_to_hex[2..]

        else
          raise "Extrinsics version #{version_info} is not implemented"
        end

        if result[:call_index]
          call_module, call = metadata.value.call_index[result[:call_index]]

          result[:call_function] = call[:name].downcase
          result[:call_module] = call_module[:name].downcase

          # decode params
          result[:params_raw] = scale_bytes.get_remaining_bytes.bytes_to_hex
          result[:params] = call[:args].map do |arg|
            type = Scale::Types.get(arg[:type])
            arg_obj = type.decode(scale_bytes)
            {name: arg[:name], type: type.name, value: arg_obj.value, value_raw: "0x#{arg_obj.encode}" }
          end
        end

        result[:extrinsic_length] = extrinsic_length
        result[:version_info] = version_info

        result
      end

      def encode
      end
    end

  end
end