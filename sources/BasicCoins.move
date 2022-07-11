address 0xCAED {
    module BasicCoins {

        use std::signer;
        use std::errors;

        const MODULE_OWNER :address  = @0xCAED;
        const ENOT_MODULE_OWNER:u64 = 0;
        const EALREADY_INITIALIZED : u64 = 2;
        const ENOT_ENOUGH_BALANCE : u64 = 1;

        //use std::signer;
        struct Coin has store {
            value : u64
        }

        struct Balance has key {
            coin : Coin
        }

        public fun mint(module_owner: &signer, mint_addr : address, amount : u64) acquires Balance {
            assert!(signer::address_of(module_owner) == MODULE_OWNER, errors::requires_address(ENOT_MODULE_OWNER));
            //move_to(mint_addr, Balance { coin : Coin {value : amount}})
            depsoit(mint_addr, Coin {value : amount});
        
        }
       
        public fun publish_balance(account : &signer) {

            assert!(!exists<Balance>(signer::address_of(account)), errors::already_published(EALREADY_INITIALIZED));
            move_to(account , Balance { coin : Coin {value : 0}})
        }

        public fun balance_of(owner : address):u64 acquires Balance {
            borrow_global<Balance>(owner).coin.value
        }

        public fun depsoit(addr : address, coin : Coin) acquires Balance {
            let balance = balance_of(addr);

            let balance_ref = &mut  borrow_global_mut<Balance>(addr).coin.value;
            
            let Coin {value } = coin;

            *balance_ref = balance + value;

        }

        public fun withdraw(addr : address, amount : u64) : Coin acquires Balance {
            let balance = balance_of(addr);

            assert!(balance >= amount, ENOT_ENOUGH_BALANCE);
            let balance_ref = &mut borrow_global_mut<Balance>(addr).coin.value;

            *balance_ref = balance - amount;

            Coin {value : amount}

        }

        #[test(account = @0x1)]
        #[expected_failure]
        fun mint_non_owner(account : signer) acquires Balance {
            publish_balance(&account);

            assert!(signer::address_of(&account) != MODULE_OWNER, 0);
            mint(&account, @0x1, 10);
        }

        // #[test(account = @0x1)]
        // fun publish_balance_has_zero(account :signer) acquires Balance {
        //     let addr = signer::address_of(&account);

        //     publish_balance(&account);

        //     mint(&account , @0xCAED, 42);
        //     assert!(balance_of(addr) == 0 , 0);
        // }


    }
}