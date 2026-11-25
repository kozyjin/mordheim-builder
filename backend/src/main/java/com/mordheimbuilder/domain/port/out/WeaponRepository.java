package com.mordheimbuilder.domain.port.out;

import com.mordheimbuilder.domain.model.Weapon;

import java.util.List;

public interface WeaponRepository {

    /**
     * renvoie toutes les armes, liste vide si aucune, jamais null
     * @return List<Weapon>
     */
    List<Weapon> findAll();

}
