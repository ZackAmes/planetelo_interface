use starknet::{ContractAddress, ClassHash, contract_address_const};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait, Resource};

use planetary_interface::utils::systems::{get_world_contract_address};

#[starknet::interface]
trait IPlanetaryActions<TState> {
    fn register(ref self: TState, name: felt252, world_address: ContractAddress);
    fn unregister(ref self: TState, name: felt252);
    fn get_world_address(ref self: TState, name: felt252) -> ContractAddress;
}

#[derive(Copy, Drop)]
struct PlanetaryInterface {
    world: IWorldDispatcher
}

#[generate_trait]
impl PlanetaryInterfaceImpl of PlanetaryInterfaceTrait {

    const ACTIONS_SELECTOR: felt252 = selector_from_tag!("planetary-planetary_actions");

    fn WORLD_CONTRACT() -> ContractAddress {
        (starknet::contract_address_const::<0x12e4037b9904e439251127d689aed16e4494c3e82a12982ed3183d7bf29350b>())
    }
    //
    // create a new interface
    fn new() -> PlanetaryInterface {
        (PlanetaryInterface{ 
            world: IWorldDispatcher{contract_address: Self::WORLD_CONTRACT()}
        })
    }
    fn new_custom(world_address: ContractAddress) -> PlanetaryInterface {
        (PlanetaryInterface{ 
            world: IWorldDispatcher{contract_address: world_address}
        })
    }

    //
    // dispatchers
    fn dispatcher(self: PlanetaryInterface) -> IPlanetaryActionsDispatcher {
        (IPlanetaryActionsDispatcher{
            contract_address: get_world_contract_address(self.world, Self::ACTIONS_SELECTOR)
        })
    }
}
