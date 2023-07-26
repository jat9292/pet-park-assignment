//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract PetPark {
    enum AnimalType {
        None,
        Fish,
        Cat,
        Dog,
        Rabbit,
        Parrot
    }
    enum Gender {
        Male,
        Female
    }
    struct Human {
        Gender gender;
        uint256 age;
    }
    mapping(address => Human) descriptionSubscribedHuman;
    event Added(AnimalType indexed animalType, uint256 animalCount);
    event Borrowed(AnimalType indexed animalType);
    event Returned(AnimalType indexed animalType);

    address private _owner;
    mapping(address borrower => AnimalType) hasBorrowedAnimal;
    mapping(AnimalType => uint256) public animalCounts;

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == _owner, "Non owner cannot add animal");
        _;
    }

    constructor() {
        _owner = msg.sender;
    }

    function add(
        AnimalType animalType,
        uint256 animalCount
    ) external onlyOwner {
        require(animalType != AnimalType.None, "Invalid animal");
        animalCounts[animalType] += animalCount;
        emit Added(animalType, animalCount);
    }

    function borrow(uint age, Gender gender, AnimalType animalType) external {
        require(age > 0, "Age must be positive");
        if (descriptionSubscribedHuman[msg.sender].age == 0) {
            descriptionSubscribedHuman[msg.sender].age = age;
            descriptionSubscribedHuman[msg.sender].gender = gender;
        } else {
            require(
                descriptionSubscribedHuman[msg.sender].age == age,
                "Invalid Age"
            );
            require(
                descriptionSubscribedHuman[msg.sender].gender == gender,
                "Invalid Gender"
            );
        }
        require(animalType != AnimalType.None, "Invalid animal type");
        require(
            hasBorrowedAnimal[msg.sender] == AnimalType.None,
            "Already adopted a pet"
        );
        require(animalCounts[animalType] > 0, "Selected animal not available");

        if (gender == Gender.Male) {
            require(
                animalType == AnimalType.Dog || animalType == AnimalType.Fish,
                "Invalid animal for men"
            );
        }
        if (gender == Gender.Female && animalType == AnimalType.Cat) {
            require(age >= 40, "Invalid animal for women under 40");
        }

        hasBorrowedAnimal[msg.sender] = animalType;
        animalCounts[animalType] -= 1;
        emit Borrowed(animalType);
    }

    function giveBackAnimal() external {
        AnimalType borrowedAnimal = hasBorrowedAnimal[msg.sender];
        require(borrowedAnimal != AnimalType.None, "No borrowed pets");
        animalCounts[borrowedAnimal] += 1;
        hasBorrowedAnimal[msg.sender] = AnimalType.None;
        emit Returned(borrowedAnimal);
    }
}
