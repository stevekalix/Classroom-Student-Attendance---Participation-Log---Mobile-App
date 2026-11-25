package com.classtrack.exception;
public class DuplicateResourceException extends ApiException { public DuplicateResourceException(String message) { super(409,"DUPLICATE_ROLL_ID",message); } }
