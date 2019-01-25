using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class BallController : MonoBehaviour
{
    float _topSpeed = 4.0f;
    Vector3 _velocity;
    float _speedSmoothFactor = 10f;

    void Update()
    {
        Vector3 movement = Vector3.zero;

        if (Input.GetKey(KeyCode.LeftArrow))
            movement.x -= 1;
        if (Input.GetKey(KeyCode.RightArrow))
            movement.x += 1;

        _velocity = Vector3.Lerp(_velocity, movement * _topSpeed, Time.deltaTime * _speedSmoothFactor);

        transform.position += _velocity * Time.deltaTime;
    }
}