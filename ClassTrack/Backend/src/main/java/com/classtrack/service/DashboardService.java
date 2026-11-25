package com.classtrack.service;
import java.time.LocalDate;
import com.classtrack.dto.response.DashboardResponse;
public interface DashboardService { DashboardResponse summary(LocalDate date); }
