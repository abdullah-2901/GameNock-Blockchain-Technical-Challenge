module abdullah_zubair::challenge {
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::url::{Self, Url};
    use std::string::{Self, String};
    use std::ascii::string as ascii_string;
    use std::vector;

    /// Shared object to store asset metadata
    struct AssetMetadata has key {
        id: UID,
        title: String,
        asset_type: String,
        mint_supply: u64,
        base_image_url: Url,
        minted_count: u64,
    }

    /// Object representing each minted asset
    struct PubliclyTransferrableObject has key, store {
        id: UID,
        mint_number: u64,
        image_url: Url,
    }

    /// Error codes
    const EMintLimitReached: u64 = 0;
    const EInvalidMintNumber: u64 = 1;

    /// Initialize the shared AssetMetadata
    fun init(ctx: &mut TxContext) {
        let metadata = AssetMetadata {
            id: object::new(ctx),
            title: string::utf8(b"GameNock Challenge Asset"),
            asset_type: string::utf8(b"Challenge"),
            mint_supply: 200,
            base_image_url: url::new_unsafe(ascii_string(b"https://i.pinimg.com/564x/50/08/ef/5008efb9df96969624d2674645027a3a.jpg")),
            minted_count: 0,
        };
        transfer::share_object(metadata);
    }

    /// Mint a new PubliclyTransferrableObject
    public entry fun mint(
        metadata: &mut AssetMetadata,
        mint_number: u64,
        ctx: &mut TxContext
    ) {
        assert!(metadata.minted_count < metadata.mint_supply, EMintLimitReached);
        assert!(mint_number > 0 && mint_number <= metadata.mint_supply, EInvalidMintNumber);

        let base_url = b"https://i.pinimg.com/564x/50/08/ef/5008efb9df96969624d2674645027a3a.jpg";
        let mint_number_str = u64_to_string(mint_number);
        let full_url = vector::empty();
        vector::append(&mut full_url, base_url);
        vector::append(&mut full_url, b"_");
        vector::append(&mut full_url, *string::as_bytes(&mint_number_str));
        
        let ascii_url = ascii_string(full_url);
        let image_url = url::new_unsafe(ascii_url);

        let asset = PubliclyTransferrableObject {
            id: object::new(ctx),
            mint_number,
            image_url,
        };

        metadata.minted_count = metadata.minted_count + 1;
        transfer::public_transfer(asset, tx_context::sender(ctx));
    }
    /// Convert u64 to string
    fun u64_to_string(value: u64): String {
        if (value == 0) {
            return string::utf8(b"0")
        };
        let buffer = vector::empty<u8>();
        while (value != 0) {
            vector::push_back(&mut buffer, ((48 + value % 10) as u8));
            value = value / 10;
        };
        vector::reverse(&mut buffer);
        string::utf8(buffer)
    }

    /// View functions
    public fun get_title(metadata: &AssetMetadata): &String { &metadata.title }
    public fun get_type(metadata: &AssetMetadata): &String { &metadata.asset_type }
    public fun get_mint_supply(metadata: &AssetMetadata): u64 { metadata.mint_supply }
    public fun get_base_image_url(metadata: &AssetMetadata): &Url { &metadata.base_image_url }

    public fun get_minted_count(metadata: &AssetMetadata): u64 { metadata.minted_count }
    public fun get_mint_number(asset: &PubliclyTransferrableObject): u64 { asset.mint_number }
    public fun get_image_url(asset: &PubliclyTransferrableObject): &Url { &asset.image_url }
}