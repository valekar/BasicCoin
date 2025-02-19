module 0xCAFE::BasicCoin {

    #[test_only]
    use std::signer;
     
    struct Coin has key {
        value : u64
    }

    public fun mint(account : signer , value : u64) {
        //let Coin {value }= new(value);
        //debug::print(&value);
        move_to(&account, new(value))
    }

    fun new(value : u64) : Coin {
        Coin {
            value : value 
        }
    }

    #[test(account = @0xC0FFEE)]
    fun test_mint_10(account: signer) acquires Coin {

        let addr = signer::address_of(&account);
        mint(account, 10);

        assert!(borrow_global<Coin>(addr).value == 10, 1);
    }
}