package Infrastructure;

import jakarta.persistence.*;

import java.sql.Timestamp;

@Entity
public class UserModel {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long Id;

    @Column(nullable = false, length = 100)
    private String FirstName;

    @Column(nullable = false, length = 100)
    private String LastName;

    @Column(nullable = false, length = 20)
    private String Cedula;

    @Column(nullable = false, length = 150)
    private String Email;

    @Column(nullable = false, length = 255)
    private String Password;

    @Column(nullable = false, length = 20)
    private String Phone;

    @Column(nullable = false, length = 255)
    private String Address;

    @Column(nullable = false)
    private boolean IsActive;

    @Column(nullable = false)
    private Timestamp CreatedAt;

    @Column(nullable = false)
    private Timestamp UpdatedAt;
}
