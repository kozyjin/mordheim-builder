package com.mordheimbuilder.application.usecase;

import com.mordheimbuilder.application.port.in.ListWeaponsUseCase;
import com.mordheimbuilder.domain.model.Weapon;
import com.mordheimbuilder.domain.port.out.WeaponRepository;

import java.util.List;

public class ListWeaponsService implements ListWeaponsUseCase {

    private final WeaponRepository weaponRepository;

    public ListWeaponsService(WeaponRepository weaponRepository){
        this.weaponRepository = weaponRepository;
    }

    @Override
    public List<Weapon> listWeapons() {
        return weaponRepository.findAll();
    }
}
