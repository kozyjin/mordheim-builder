package com.mordheimbuilder.domain.model;

import java.util.Objects;
import java.util.UUID;

public record SpecialRule(UUID id, String name, String description) {

    public SpecialRule{

        Objects.requireNonNull(id,"id");
        Objects.requireNonNull(name,"name");
        Objects.requireNonNull(description,"description");

        if(name.isBlank()){
            throw new IllegalArgumentException("name must be not blank");
        }

        if(description.isBlank()){
            throw new IllegalArgumentException("description must be not blank");
        }

    }

}
