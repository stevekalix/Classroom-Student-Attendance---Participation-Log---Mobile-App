package com.classtrack.dto.response;
import java.util.List;
public record PageResponse<T>(List<T> content,int number,int totalPages,long totalElements) {}
