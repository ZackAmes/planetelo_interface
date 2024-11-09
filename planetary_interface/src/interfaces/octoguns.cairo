use starknet::{ContractAddress, ClassHash, contract_address_const};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait, Resource};

use planetary_interface::utils::systems::{get_world_contract_address};
use planetary_interface::interfaces::planetary::{
    PlanetaryInterface, PlanetaryInterfaceTrait,
    IPlanetaryActionsDispatcher, IPlanetaryActionsDispatcherTrait,
};

// for planetary interface
#[derive(Drop, Serde)]
pub struct SessionMeta {
    pub session_id: u32,
    pub turn_count: u32, // mod 2 = 1 is player 2 and mod 2 = 0 is player 1
    pub p1_character: u32,
    pub p2_character: u32,
    pub bullets: Array<u32>,
}

#[derive(Copy, Drop, Serde, Introspect)]
pub struct Settings {
    pub bullet_speed: u64,
    pub bullet_sub_steps: u32,
    pub bullets_per_turn: u32,
    pub sub_moves_per_turn: u32,
    pub max_distance_per_sub_move: u32,
}

#[derive(Copy, Drop, Serde, Introspect)]
struct Shot {
    angle: u64, // 0 to 360
    step: u32,
}

#[derive(Clone, Drop, Serde, Introspect)]
struct TurnMove {
    sub_moves: Array<IVec2>,
    shots: Array<Shot>,
}

#[derive(Copy, Drop, Serde, Introspect)]
struct IVec2 {
    x: u64,
    y: u64,
    xdir: bool,
    ydir: bool
}

#[starknet::interface]
trait IOctogunsStart<TState> {

    fn create(ref self: TState, map_id: u32, settings: Settings) -> u32;
    fn create_closed(
        ref self: TState,
        map_id: u32,
        player_address_1: ContractAddress,
        player_address_2: ContractAddress,
        settings: Settings
    ) -> u32;
    fn join(ref self: TState, session_id: u32);
    fn pew(ref self: TState) -> felt252;
}

#[starknet::interface]
trait IOctogunsSpawn<TState> {
    fn spawn(ref self: TState, session_id: u32);
}

#[starknet::interface]
trait IOctogunsActions<TState> {
    fn move(ref self: TState, session_id: u32, moves: TurnMove);
}



#[derive(Copy, Drop)]
struct OctogunsInterface {
    world: IWorldDispatcher
}

#[generate_trait]
impl OctogunsInterfaceImpl of OctogunsInterfaceTrait {
    
    const NAMESPACE: felt252 = 'octoguns';
    const ACTIONS_SELECTOR: felt252 = selector_from_tag!("octoguns-actions");
    const START_SELECTOR: felt252 = selector_from_tag!("octoguns-start");
    const SPAWN_SELECTOR: felt252 = selector_from_tag!("octoguns-spawn");
    
    fn new() -> OctogunsInterface {
        let world_address: ContractAddress = PlanetaryInterfaceTrait::new().dispatcher().get_world_address(Self::NAMESPACE);
        (OctogunsInterface{
            world: IWorldDispatcher{contract_address: world_address}
        })
    }

    //
    // dispatchers
    fn actions_dispatcher(self: OctogunsInterface) -> IOctogunsActionsDispatcher {
        (IOctogunsActionsDispatcher{
            contract_address: get_world_contract_address(self.world, Self::ACTIONS_SELECTOR)
        })
    }

    fn start_dispatcher(self: OctogunsInterface) -> IOctogunsStartDispatcher {
        (IOctogunsStartDispatcher{
            contract_address: get_world_contract_address(self.world, Self::START_SELECTOR)
        })
    }

    fn spawn_dispatcher(self: OctogunsInterface) -> IOctogunsSpawnDispatcher {
        (IOctogunsSpawnDispatcher{
            contract_address: get_world_contract_address(self.world, Self::SPAWN_SELECTOR)
        })
    }   

}
