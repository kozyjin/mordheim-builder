package com.mordheimbuilder.domain.model;

import org.junit.jupiter.api.Test;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

class WeaponTest {

    //methode utilitaire
    private Weapon weaponCreate(boolean isShootingWeapon, boolean isCloseCombatWeapon){

        return new Weapon(UUID.randomUUID(),"Epee","Utilisateur","corps à corps",6,"Commun",isShootingWeapon,isCloseCombatWeapon,List.of());
    }

    @Test
    void shouldCreateWeapon(){
        ArrayList<SpecialRule> specialRules = new ArrayList<>();
        Weapon weapon = weaponCreate(true, false);
        assertEquals("Epee",weapon.name());
        assertEquals(6,weapon.cost());
        assertTrue(weapon.isShootingWeapon());
        assertFalse(weapon.isCloseCombatWeapon());
    }

    @Test
    void shouldNotCreateWeaponNameIsNull(){
        List<SpecialRule> specialRules = List.of();
        assertThrows(NullPointerException.class,
                () -> new Weapon(UUID.randomUUID(),null,"F+1","20",6,"Commun",true,false,specialRules));

    }

    @Test
    void shouldNotCreateWeaponIdIsNull(){
        List<SpecialRule> specialRules = List.of();
        assertThrows(NullPointerException.class,
                () -> new Weapon(null,"Name","F+1","20",6,"Commun",true,false,specialRules));
    }


    @Test
    void shouldRejectBlankName(){
        List<SpecialRule> specialRules = List.of();
        assertThrows(IllegalArgumentException.class,
                () -> new Weapon(UUID.randomUUID()," ","F+1","10",6,"Commun",true,false,specialRules));
    }

    @Test
    void shouldRejectCostIsNegatif(){
        List<SpecialRule> specialRules = List.of();
        assertThrows(IllegalArgumentException.class,
                () -> new Weapon(UUID.randomUUID(),"TestName","F+1","10",-6,"Commun",true,false,specialRules));
    }

    @Test
    void shouldRejetaWeaponWhithoutAType(){
        List<SpecialRule> specialRules = List.of();
        assertThrows(IllegalArgumentException.class,
                () -> new Weapon(UUID.randomUUID(),"TestName","F+1","10",6,"Commun",false,false,specialRules));
    }

    @Test
    void shouldAcceptAWeaponWithAType() {
        Weapon weapon =  weaponCreate(true, false);

        assertTrue(weapon.isShootingWeapon());
        assertFalse(weapon.isCloseCombatWeapon());
    }
    @Test
    void shouldAcceptAWeaponWithTwoTypes(){
        Weapon weapon = weaponCreate(true, true);

        assertTrue(weapon.isShootingWeapon());
        assertTrue(weapon.isCloseCombatWeapon());
    }

    @Test
    void shouldNotBeAffectedByLaterChangesToTheOriginalList(){
        ArrayList<SpecialRule> specialRuleTest = new ArrayList<>();
        specialRuleTest.add(new SpecialRule(UUID.randomUUID(),"parade","annule une attaque"));
        Weapon weapon = new Weapon(UUID.randomUUID(),"TestName","F+1","10",6,"Commun",true,false,specialRuleTest);

        assertEquals(1,weapon.specialRules().size());
    }

    @Test
    void shouldRejectAListOfSpecialRulesHasNull(){
        ArrayList<SpecialRule> specialRules = null;
        assertThrows(NullPointerException.class,
                () -> new Weapon(UUID.randomUUID(),"TestName","F+1","10",6,"Commun",true,false,specialRules));
    }

}



