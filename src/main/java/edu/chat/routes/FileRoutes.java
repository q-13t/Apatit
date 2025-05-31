package edu.chat.routes;

import java.sql.ResultSet;
import java.sql.SQLException;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Service;

import edu.chat.views.FileView;

class FIleMapper implements RowMapper<FileView> {

    @Override
    public FileView mapRow(ResultSet result, int arg1) throws SQLException {
        FileView file = new FileView();
        file.setId(result.getInt("id"));
        file.setFile_name(result.getString("file_name"));
        file.setFile_extension(result.getString("file_extension"));
        file.setFile_url(result.getString("file_url"));
        return file;
    }

}

@Service
public class FileRoutes {
    private Logger log = LogManager.getLogger(UserRoutes.class.getName());
    @Autowired
    private JdbcTemplate jdbcTemplate;

    public FileView getFileByID(int id) {
        try {
            return jdbcTemplate.queryForObject("SELECT * FROM file WHERE id = ?", new FIleMapper(), id);
        } catch (DataAccessException e) {
            log.error("File not found");
            return null;
        }
    }

    public FileView getFileByUUID(String uuid) {
        try {
            return jdbcTemplate.queryForObject("SELECT * FROM file WHERE file_uuid = ?", new FIleMapper(), uuid);
        } catch (DataAccessException e) {
            log.error("File not found");
            return null;
        }
    }
}
