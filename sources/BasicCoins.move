address 0xCAED {
    module BasicCoins {

        use std::signer;
        use std::errors;
       // use std::debug;



        const MODULE_OWNER :address  = @0xCAED;
        const ENOT_MODULE_OWNER:u64 = 0;
        const EALREADY_INITIALIZED : u64 = 2;
        const ENOT_ENOUGH_BALANCE : u64 = 1;

        //use std::signer;
        struct Coin<phantom CoinT> has store {
            value : u64
        }

        struct Balance<phantom CoinT> has key {
            coin : Coin<CoinT>
        }

        public fun mint<CoinT>(module_owner: &signer, mint_addr : address, amount : u64) acquires Balance {
            assert!(signer::address_of(module_owner) == MODULE_OWNER, errors::requires_address(ENOT_MODULE_OWNER));
            //move_to(mint_addr, Balance { coin : Coin {value : amount}})
            depsoit<CoinT>(mint_addr, Coin<CoinT> {value : amount});
        
        }
       
        public fun publish_balance<CoinT>(account : &signer) {

            assert!(!exists<Balance<CoinT>>(signer::address_of(account)), errors::already_published(EALREADY_INITIALIZED));
            let empty_coin = Coin<CoinT>{value : 0};
            move_to(account , Balance<CoinT>{ coin : empty_coin})
        }

        public fun balance_of<CoinT>(owner : address):u64 acquires Balance {
            borrow_global<Balance<CoinT>>(owner).coin.value
        }

        public fun depsoit<CoinT>(addr : address, check : Coin<CoinT>) acquires Balance {
            let balance = balance_of<CoinT>(addr);
            let balance_ref = &mut borrow_global_mut<Balance<CoinT>>(addr).coin.value;
            let Coin { value } = check;
            *balance_ref = balance + value;

        }

        public fun withdraw<CoinT>(addr : address, amount : u64) : Coin<CoinT> acquires Balance {
            let balance = balance_of<CoinT>(addr);

            assert!(balance >= amount, ENOT_ENOUGH_BALANCE);
            let balance_ref = &mut borrow_global_mut<Balance<CoinT>>(addr).coin.value;

            *balance_ref = balance - amount;

            Coin<CoinT>{value : amount}

        }

        #[test(account = @0x1)]
        #[expected_failure]
        fun mint_non_owner<CoinT>(account : signer) acquires Balance {
            publish_balance<CoinT>(&account);

            assert!(signer::address_of(&account) != MODULE_OWNER, 0);
            mint<CoinT>(&account, @0x1, 10);
        }

        #[test(account = @0xCAED)]
        fun mint_check_balance<CoinT>(account :signer) acquires Balance {
            let addr = signer::address_of(&account);

            publish_balance<CoinT>(&account);

            mint<CoinT>(&account , @0xCAED, 42);
            assert!(balance_of<CoinT>(addr) == 42 , 0);
        }

        #[test(account = @0x1)]
        fun publish_balance_has_zero<CoinT>(account : signer) acquires Balance {
            let addr = signer::address_of(&account);
            publish_balance<CoinT>(&account);
            assert!(balance_of<CoinT>(addr) == 0 , 0);
        }

        #[test(account = @0x1)]
        #[expected_failure(abort_code = 518)]
        fun publish_balance_already_exists<CoinT>(account : signer) {
            publish_balance<CoinT>(&account);
            publish_balance<CoinT>(&account);
        }

        #[test(account = @0x1)]
        #[expected_failure]
        fun withdraw_dne<CoinT>() acquires Balance {
            let Coin { value } = withdraw<CoinT>(@0x1, 1);
            let _ = value;
        }

        #[test(account = @0x1)]
        #[expected_failure]
        fun withdraw_too_much<CoinT>(account : signer) acquires Balance {
            let addr = signer::address_of(&account);
            publish_balance<CoinT>(&account);
            Coin {value : _} = withdraw<CoinT>(addr, 1);
        }

        #[test(account = @0xCAED)]
        fun can_withdraw_amount<CoinT>(account : signer) acquires Balance {
            publish_balance<CoinT>(&account);
            let addr = signer::address_of(&account);
            mint<CoinT>(&account, addr, 1000);

            let Coin<CoinT>{ value } = withdraw<CoinT>(addr, 50);
            //debug::print(&value);

            assert!(balance_of<CoinT>(addr) == 950, 1);
            assert!(value == 50, 0);
        }


        #[test(account = @0x1)]
        #[expected_failure]
        fun balance_dne<CoinT>(account : signer) acquires Balance {
            let addr = signer::address_of(&account);
            balance_of<CoinT>(addr);
        }


    }
}