// SPDX-License-Identifier: GPL-3.0

// Book library Exercise
// - The administrator (owner) of the library should be able to add new books and the number of copies in the library.
// - Users should be able to see the available books and borrow them by their id.
// - Users should be able to return books.
// - A user should not borrow more than one copy of a book at a time. The users should not be able to borrow a book more times than the copies in the libraries unless copy is returned.
// - Everyone should be able to see the addresses of all people that have ever borrowed a given book.

pragma solidity ^0.8.7;
pragma abicoder v2;

import "./libraries/Owner.sol";

contract BookLibrary is Owner {

  struct Book {
    uint id;
    uint copies;
    uint available;
    string title;
    string author;
  }

  Book[] books;

  mapping(address => uint) public borrowed;
  mapping(uint => address[]) history;

  event BookAdded(string author, string title, uint copies);
  event BookBorrowed(string author, string title, uint available, address user);
  event BookReturned(string author, string title, uint available, address user);

  constructor() {
    address _owner = msg.sender;
    emit OwnerSet(address(0), _owner);
  }

  modifier itExists(uint _id) {
    require(_id > 0 && _id <= books.length, "Please provide a correct ID");
    _;
  }

  modifier isAvailable(uint _id) {
    require(books[_id - 1].available > 0, "All copies are borrowed");
    _;
  }

  modifier canBorrow() {
    require(borrowed[msg.sender] == 0, "You can borrow one book at a time");
    _;
  }

  function getBook(uint _id) public view itExists(_id) returns (
    uint id,
    uint copies,
    uint available,
    string memory title,
    string memory author
  ) {
    Book memory _book = books[_id - 1];
    return (_book.id, _book.copies, _book.available, _book.title, _book.author);
  }

  function getBooks() public view returns (Book[] memory) {
    return books;
  }
  
  function getBorrowers(uint _id) public view itExists(_id) returns (address[] memory) {
    return history[_id];
  }

  function getAllAvailableBooks() public view returns (Book[] memory) {
    uint _count = 0;
    for (uint i = 0; i < books.length; i++) {
      if (books[i].available > 0) {
        _count++;
      }
    }
    Book[] memory _available = new Book[](_count);
    _count = 0;
    for (uint i = 0; i < books.length; i++) {
      if (books[i].available > 0) {
        _available[_count] = books[i];
        _count++;
      }
    }
    return _available;
  }

  function borrowBook(uint _id) public itExists(_id) isAvailable(_id) canBorrow {
    borrowed[msg.sender] = _id;
    Book storage _book = books[_id - 1];
    _book.available--;
    history[_id].push(msg.sender);
    emit BookBorrowed(_book.author, _book.title, _book.available, msg.sender);
  }
  
  function returnBook(uint _id) public itExists(_id) {
    require(borrowed[msg.sender] == _id, "You don't have borrowed this book");
    borrowed[msg.sender] = 0;
    Book memory _book = books[_id - 1];
    _book.available++;
    emit BookReturned(_book.author, _book.title, _book.available, msg.sender);
  }

  function addBook(string memory _title, string memory _author, uint _copies) public isOwner {
    require(_copies > 0, "At least one copy is required");
    uint _id = books.length + 1;
    Book memory _book = Book(_id, _copies, _copies, _title, _author);
    books.push(_book);
    emit BookAdded(_book.author, _book.title, _book.copies);
  }

  function modifyCopies(uint _id, uint _copies) public isOwner itExists(_id) {
    books[_id - 1].copies = _copies;
    if (books[_id - 1].copies < books[_id - 1].available) {
      books[_id - 1].available = _copies;
    }
  }
}