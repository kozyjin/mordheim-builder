package com.mordheimbuilder.domain.model;

import java.util.List;
import java.util.Objects;
import java.util.UUID;

public record Weapon(UUID id, String name, String strength, String range,
                     int cost, String rarity, boolean isShootingWeapon, boolean isCloseCombatWeapon, List<SpecialRule> specialRules) {


    public Weapon{
        Objects.requireNonNull(id,"id");
        Objects.requireNonNull(name,"name");
        specialRules = List.copyOf(specialRules);

         if(!isCloseCombatWeapon && !isShootingWeapon){
            throw new IllegalArgumentException("The weapon must be either a close-combat weapon or a firearm. Not false for both");
        }
         if(name.isBlank()){
             throw new IllegalArgumentException("name must not be blank");
         }

         if(cost < 0){
             throw new IllegalArgumentException("cost must be >= 0");
         }

    }
}
